#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler
import subprocess as sp
from sklearn.neighbors import KNeighborsClassifier
import pickle
from bson.binary import Binary
import json
import numpy as np

import base64
import os
from PIL import Image
import cv2

from tornado import gen

def formatDictResult(checkList):
    result = ""
    for k,v in checkList.items():
        if k =="UNKNOWN":
            continue

        if v == False:
            s = "{:18s} {:6s}\n".format(k, '❌')
            result = result+s
        else:
            s = "{:18s} {:6s}\n".format(k, '✅')
            result = s+result 

    return result


# Take in base64 string and return cv image
def stringToRGB(base64_string):
    img = base64.b64decode(str(base64_string)); 
    npimg = np.fromstring(img, dtype=np.uint8); 
    source = cv2.imdecode(npimg, 1)
    source = cv2.resize(source,(300,400))

    return source

def get_prediction(clf,class_names,face):
    predictions = clf.predict_proba(face)
    best_class_indices = np.argmax(predictions, axis=1)
    best_class_probabilities = predictions[np.arange(len(best_class_indices)), best_class_indices]
    
    sig_test = list(predictions[0])
    del sig_test[best_class_indices[0]]

    arrstd = np.std(sig_test)
    arrmean = np.mean(sig_test)
    right = arrmean+3.5*arrstd
    print(sig_test)
    print(arrmean,arrstd,right,best_class_probabilities[0])

    if best_class_probabilities[0] > 0.45 and best_class_probabilities[0]> right:
        pre=float(best_class_probabilities[0])*100
        pre= round(pre,2)
        pre=str(pre)+'%'
        a=class_names[best_class_indices[0]].split(' ')
        result=a[0]
        predict_result = str(result+' '+pre)
        name = str(result)
        # self.write_json({"prediction":str(result+' '+pre)})
    else:
        predict_result = str("UNKNOWN")
        name = predict_result
        # self.write_json({"prediction":str("UNKNOWN")})
    return predict_result, name

class PrintHandlers(BaseHandler):
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),','),\n'))

class UploadLabeledDatapointHandler(BaseHandler):
    def post(self):
        '''Save data point and class label to database
        '''
        data = json.loads(self.request.body.decode("utf-8"))

        vals = data['feature']
        image = stringToRGB(vals)
        # vals = image
        print('\n\n\n\n',image.shape)
        # fvals = [float(val) for val in vals]
        label = data['label']
        sess  = data['dsid']
        self.RF_est_number = int(data['Parameter'])
        dbid = self.db.labeledinstances.insert(
            {"feature":vals,"label":label,"dsid":sess}
            );

        face = self.faceEmbedding(image)
        if type(face) == int:
            if face == -1:
                self.write_json({"id":str(dbid),
                "feature":vals,
                "label":label,
                "status":"No face detected.Show one face at a time"})
                return
            if face == 0:
                self.write_json({"id":str(dbid),
                "feature":vals,
                "label":label,
                "status":"multiple faces detected.Slease show one face at a time"})
                return
        print('\n\n\n\n',face.shape)

        # save image 
        directory = self.image_dataset_dir + '/'+label+'/'
        if not os.path.exists(directory):
            os.makedirs(directory)

        rmDS = 'rm '+directory+'.DS_Store'
        if '.DS_Store' in os.listdir(directory):
            flag=sp.call(rmDS,shell=True)

        img_number=len(os.listdir(directory))
            # Filename 
        filename = directory+label+'_'+str(img_number+1)+'.png'
          
        # Using cv2.imwrite() method 
        # Saving the image 
        cv2.imwrite(filename, image) 

        if '.DS_Store' in os.listdir(directory):
            flag=sp.call(rmDS,shell=True)

        self.write_json({"id":str(dbid),
            "feature":vals,
            "label":label,
            "status":"Success!"})


class RequestNewDatasetId(BaseHandler):
    def get(self):
        '''Get a new dataset ID for building a new dataset
        '''
        a = self.db.labeledinstances.find_one(sort=[("dsid", -1)])
        if a == None:
            newSessionId = 1
        else:
            newSessionId = float(a['dsid'])+1
        self.write_json({"dsid":newSessionId})

class UpdateModelForDatasetId(BaseHandler):

    @gen.coroutine
    def model_training(self):
        dsid = self.get_int_arg("dsid",default=0)
        data_folder = './mtcnnFacesData'
        face_net_model = '/Users/xqu/datasets/pretrain/20180402-114759.pb'
        output_model = './model/mySVMmodel.pkl'
        RF_model = './model/RFmodel.pkl'
        batch_size = 10
        augment_times = 20

        face_detection_corp_face ="""python src/align/align_dataset_mtcnn.py \
                                ./imageData \
                                ./mtcnnFacesData \
                                --image_size 160 \
                                --margin 32 \
                                --random_order
        """

        print("Now croping face from image........\n\n")
        print('self.RF_est_number', self.RF_est_number)
        flag=sp.call(face_detection_corp_face,shell=True)
        if flag!=0:
            raise Exception('Please check python src/align/align_dataset_mtcnn.py  cmd ')
        else:
            print('\nFinished')

        cmd = """python myclassifier.py TRAIN \
        {} \
        {} \
        {} \
        --batch_size {} \
        --augment_times {} \
        --RandomForestPath {} \
        --n_estimators {}
        """.format(data_folder,face_net_model,output_model,batch_size,augment_times,RF_model,self.RF_est_number)

        print("Now runing myclassifer........")
        flag=sp.call(cmd,shell=True)
        if flag!=0:
            raise Exception('Please check python myclassifier.py cmd ')
        else:
            print('\nFinished')

        with open(RF_model, 'rb') as infile:
            (RFmodel, class_names) = pickle.load(infile)
            self.clf['RF'] = RFmodel

        with open(output_model, 'rb') as infile:
            (model, class_names) = pickle.load(infile)
            self.clf['SVM'] = model
            self.class_names = class_names
            bytes = pickle.dumps(self.clf)
            self.db.models.update({"dsid":dsid},
                {  "$set": {"model":Binary(bytes)}  },
                upsert=True)

        raise gen.Return("Async training Finished")


    # @web.asynchronous
    @gen.coroutine
    def get(self):
        '''Train a new model (or update) for given dataset ID
        '''
        
        status = yield self.model_training()
            # send back the resubstitution accuracy
            # if training takes a while, we are blocking tornado!! No!!
        self.write_json({"log":status})



class PredictOneFromDatasetId(BaseHandler):
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        # data = json.loads(self.request.body.decode("utf-8"))    

        # vals = data['feature'];
        # fvals = [float(val) for val in vals];
        # fvals = np.array(fvals).reshape(1, -1)
        # dsid  = data['dsid']

        # # load the model from the database (using pickle)
        # # we are blocking tornado!! no!!
        # if(self.clf == []):
        #     print('Loading Model From DB')
        #     tmp = self.db.models.find_one({"dsid":dsid})
        #     self.clf = pickle.loads(tmp['model'])
        # predLabel = self.clf.predict(fvals);
        # self.write_json({"prediction":str(predLabel)})
        data = json.loads(self.request.body.decode("utf-8"))

        vals = data['feature']
        image = stringToRGB(vals)
        cv2.imwrite('test.png', image) 
        print('\n\n\n\n',image.shape)

        # sess  = data['dsid']
        try:
            face = self.faceEmbedding(image)
        except:
            face = -1
        if type(face) == int:
            if face == -1:
                self.write_json({"prediction":str("No face detected.Show one face at a time"),
                                "RFprediction":str("No face detected.Show one face at a time"),
                                "name":"UNKNOWN",
                                "RF_est_number":str(self.RF_est_number)
                                    })
                return
            if face == 0:
                self.write_json({"prediction":str("multiple faces detected...please show one face at a time"),
                        "RFprediction":str("multiple faces detected.Show one face at a time"),
                        "name":"UNKNOWN",
                        "RF_est_number":str(self.RF_est_number)})
                return

        print('\n\n\n',face.shape)
        if self.clf == {}:
            with open(self.classifier_filename_exp, 'rb') as infile:
                (model, class_names) = pickle.load(infile)
                self.clf["SVM"] = model
                self.class_names = class_names

            with open(self.RF_path, 'rb') as infile:
                (RFmodel, class_names) = pickle.load(infile)
                self.clf["RF"] = RFmodel

        svm_re,name =get_prediction(self.clf["SVM"],self.class_names,face)

        predictions = self.clf["RF"].predict_proba(face)
        best_class_indices = np.argmax(predictions, axis=1)
        best_class_probabilities = predictions[np.arange(len(best_class_indices)), best_class_indices]
        
        a=self.class_names[best_class_indices[0]].split(' ')
        result=a[0]
        RFpredict_result = str(result)
        print(name)
        self.write_json({"name":name,
                        "prediction":svm_re,
                        "RFprediction":RFpredict_result,
                        "RF_est_number":str(self.RF_est_number)
                        })
        # update place! Need to check Blink!!
        # if Blink == True then do update
        if self.isBlink:
            self.checkList[name] = True
            self.isBlink = False 

class ReturnCheckList(BaseHandler):
    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        vals = data['status']
        print(vals)
        print(self.checkList)

        self.write_json({"status":"OK",
                        "checkList":self.checkList,
                        "resultString": formatDictResult(self.checkList),

                })


class ResetCheckList(BaseHandler):
    def post(self):
        for n in self.checkList:
            self.checkList[n] = False

        self.write_json({"status":"OK",
                        "checkList":self.checkList,
                        "resultString": formatDictResult(self.checkList),

                })


class BlinkCheck(BaseHandler):
    def post(self):
        self.isBlink = True
        print("in BlinkCheck ",self.isBlink)


