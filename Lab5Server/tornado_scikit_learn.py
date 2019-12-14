#!/usr/bin/python
'''Starts and runs the scikit learn server'''

# For this to run properly, MongoDB must be running
#    Navigate to where mongo db is installed and run
#    something like $./mongod --dbpath "../data/db"
#    might need to use sudo (yikes!)

# database imports
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError


# tornado imports
import tornado.web
from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

# custom imports
from basehandler import BaseHandler
import sklearnhandlers as skh


from scipy import misc
import sys
import os
import argparse
import tensorflow as tf
import numpy as np
import facenet
import align.detect_face
import random
from time import sleep
import numpy as np
import cv2
import align.detect_face
import time
import facenet
import math
import pickle
from sklearn.svm import SVC

#--------------Argument------------------------------------------------
modeldir='/Users/xqu/datasets/pretrain/20180402-114759.pb'
classifier_filename_exp='./model/mySVMmodel.pkl'
RF_path = './model/RFmodel.pkl'
FaceImW=160
FaceImH=160
WindowWidth=600
WindowHight=400
interval=10
MAXface=20
image_dataset_dir = './imageData'
#----------------------------------------------------------------------

def init_checkList():
    names = os.listdir('./imageData')
    if '.DS_Store' in names:
        names.remove('.DS_Store')

    checkList = {}
    for n in names:
        checkList[n] = False
    return checkList


# Setup information for tornado class
define("port", default=8000, help="run on the given port", type=int)

# Utility to be used when creating the Tornado server
# Contains the handlers and the database connection
class Application(tornado.web.Application):
    def __init__(self,tfSession,MTCNNs,classifier_filename_exp,RF_path):
        '''Store necessary handlers,
           connect to database
        '''

        handlers = [(r"/[/]?", BaseHandler),
                    (r"/Handlers[/]?",        skh.PrintHandlers),
                    (r"/AddDataPoint[/]?",    skh.UploadLabeledDatapointHandler),
                    (r"/GetNewDatasetId[/]?", skh.RequestNewDatasetId),
                    (r"/UpdateModel[/]?",     skh.UpdateModelForDatasetId),     
                    (r"/PredictOne[/]?",      skh.PredictOneFromDatasetId),
                    (r"/CheckList[/]?",       skh.ReturnCheckList),
                    (r"/ResetCheckList[/]?",  skh.ResetCheckList),
                    (r"/BlinkCheck[/]?",      skh.BlinkCheck),

                    ]

        self.handlers_string = str(handlers)

        try:
            self.client  = MongoClient(serverSelectionTimeoutMS=999999) # local host, default port
            print(self.client.server_info()) # force pymongo to look for possible running servers, error if none running
            # if we get here, at least one instance of pymongo is running
            self.db = self.client.sklearndatabase # database with labeledinstances, models
            
        except ServerSelectionTimeoutError as inst:
            print('Could not initialize database connection, stopping execution')
            print('Are you running a valid local-hosted instance of mongodb?')
            #raise inst
        
        self.clf = {} # the classifier model (in-class assignment, you might need to change this line!)
        # but depending on your implementation, you may not need to change it  ¯\_(ツ)_/¯

        self.image_dataset_dir = image_dataset_dir

        self.embedding_model_path = modeldir
        self.tfSession = tfSession
        self.MTCNNs = MTCNNs
        self.classifier_filename_exp=classifier_filename_exp
        self.class_names=[]
        self.RF_path=RF_path
        self.RF_est_number=50
        self.checkList=init_checkList()
        self.isBlink=False

        settings = {'debug':True}
        tornado.web.Application.__init__(self, handlers, **settings)

    def __exit__(self):
        self.client.close() # just in case


def main():
    '''Create server, begin IOLoop 
    '''
    with tf.Graph().as_default():
        gpu_options = tf.compat.v1.GPUOptions(per_process_gpu_memory_fraction=0)
        sess = tf.compat.v1.Session(config=tf.compat.v1.ConfigProto(gpu_options=gpu_options, log_device_placement=False))
        with sess.as_default():
            pnet, rnet, onet = align.detect_face.create_mtcnn(sess, None)


    with tf.Graph().as_default():
        with tf.Session() as sess:
            print('\n\n----Loading feature extraction model----')
            facenet.load_model(modeldir)
            print('\nFinish Loading feature extraction model---')

            tornado.options.parse_command_line()
            http_server = HTTPServer(Application(sess,[pnet, rnet, onet],classifier_filename_exp,RF_path), xheaders=True)
            http_server.listen(options.port)
            IOLoop.instance().start()

if __name__ == "__main__":
    main()
