#!/usr/bin/python

# tornado imports
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options
from tornado.escape import recursive_unicode
import numpy as np
import facenet
# convenience imports
import datetime
import decimal
import json
import os
import os.path
import tensorflow as tf
from grp import getgrnam
from pwd import getpwnam
import align.detect_face
from PIL import Image
import cv2

def json_str(value):
    return str(json.dumps(recursive_unicode(value), cls=CustomJSONEncoder).replace("</", "<\\/"))

class CustomJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime.datetime):
            return obj.isoformat()
        elif isinstance(obj, datetime.date):
            return obj.isoformat()
        elif isinstance(obj, decimal.Decimal):
            return str(obj)
        else:
            return super(CustomJSONEncoder, self).default(obj)

class HTTPJSONError(Exception):
    """An exception that will turn into an HTTP error response."""
    def __init__(self, status_code, log_message=None, *args):
        self.status_code = status_code
        self.log_message = log_message
        self.args = args

    def __str__(self):
        message = {'error_code': self.status_code}
        if self.log_message:
            message['error_message'] = self.log_message % self.args
        return json_str(message)

class BaseHandler(tornado.web.RequestHandler):
    def get(self):
        '''Default get request, return a 404
           HTTP error
        '''
        raise HTTPError(404)

    @property
    def db(self):
        '''Instance getter for database connection
        '''
        return self.application.db

    @property
    def client(self):
        '''Instance getter for database connection
        '''
        return self.application.client

    @property
    def clf(self):
        '''Instance getter for current classifier
        '''
        return self.application.clf

    @property
    def class_names(self):
        '''Instance getter for current classifier
        '''
        return self.application.class_names

    @property
    def image_dataset_dir(self):
        '''Instance getter for current classifier
        '''
        return self.application.image_dataset_dir

    @property
    def embedding_model_path(self):
        '''Instance getter for current classifier
        '''
        return self.application.embedding_model_path

    @property
    def tfSession(self):
        '''Instance getter for current classifier
        '''
        return self.application.tfSession

    @property
    def MTCNNs(self):
        '''Instance getter for current classifier
        '''
        return self.application.MTCNNs      

    @property
    def classifier_filename_exp(self):
        '''Instance getter for current classifier
        '''
        return self.application.classifier_filename_exp  

    @property
    def RF_path(self):
        '''Instance getter for current classifier
        '''
        return self.application.RF_path  

    @property
    def RF_est_number(self):
        '''Instance getter for current classifier
        '''
        return self.application.RF_est_number  

    @property
    def checkList(self):
        '''Instance getter for current classifier
        '''
        return self.application.checkList  

    @property
    def isBlink(self):
        '''Instance getter for current classifier
        '''
        return self.application.isBlink  
        
    @isBlink.setter
    def isBlink(self, value):
        self.application.isBlink = value

    @checkList.setter
    def checkList(self, value):
        self.application.checkList = value

    @RF_est_number.setter
    def RF_est_number(self, value):
        self.application.RF_est_number = value

    @clf.setter
    def clf(self, value):
        self.application.clf = value

    @class_names.setter
    def class_names(self, value):
        self.application.class_names = value

    def get_int_arg(self, value, default=[], strip=True):
        '''Convenience method for grabbing integer arguments
           from HTTP headers. Will raise an HTTP error if
           argument is missing or is not an integer
        '''
        try:
            arg = self.get_argument(value, default, strip)
            return default if arg == default else int(arg) 
        except ValueError:
            e = "%s could not be read as an integer" % value
            raise HTTPJSONError(1, e)

    def get_long_arg(self, value, default=[], strip=True):
        '''Convenience method for grabbing long integer arguments
           from HTTP headers. Will raise an HTTP error if
           argument is missing or is not an integer
        '''
        try:
            arg = self.get_argument(value, default, strip)
            return default if arg == default else long(arg)
        except ValueError:
            e = "%s could not be read as a long integer" % value
            raise HTTPJSONError(1, e)

    def get_float_arg(self, value, default=[], strip=True):
        '''Convenience method for grabbing long integer arguments
           from HTTP headers. Will raise an HTTP error if
           argument is missing or is not an integer
        '''
        try:
            arg = self.get_argument(value, default, strip)
            return default if arg == default else float(arg)
        except ValueError:
            e = "%s could not be read as a long integer" % value
            raise HTTPJSONError(1, e)

    def write_json(self, value={}):
        '''Completes header and writes JSONified 
           HTTP back to client
        '''
        self.set_header("Content-Type", "application/json")
        tmp = json_str(value);
        self.write(tmp)

    def faceEmbedding(self,img):
        minsize = 20 # minimum size of face
        threshold = [ 0.6, 0.7, 0.7 ]  # three steps's threshold
        factor = 0.709 # scale factor
        bounding_boxes, _ = align.detect_face.detect_face(img, minsize, self.MTCNNs[0], self.MTCNNs[1], self.MTCNNs[2], threshold, factor)
        nrof_faces = bounding_boxes.shape[0]

        if nrof_faces > 1:
            # print('multiple faces detected...please show one face at a time')
            return 0     

        if nrof_faces < 1:
            # print('multiple faces detected...please show one face at a time')
            return -1
        else:
            for face_position in bounding_boxes:
                face_position=face_position.astype(int)
                crop=img[face_position[1]:face_position[3],face_position[0]:face_position[2],]

                scaled = cv2.resize(crop, (160, 160))
        

        images = np.zeros((1, 160, 160, 3))
        if scaled.ndim == 2:
            scaled = facenet.to_rgb(scaled)
        scaled = facenet.prewhiten(scaled)

        images[0,:,:,:]=scaled

        images_placeholder = tf.get_default_graph().get_tensor_by_name("input:0")
        embeddings = tf.get_default_graph().get_tensor_by_name("embeddings:0")
        phase_train_placeholder = tf.get_default_graph().get_tensor_by_name("phase_train:0")
        embedding_size = embeddings.get_shape()[1]
        feed_dict = { images_placeholder:images, phase_train_placeholder:False }
        emb_array = self.tfSession.run(embeddings, feed_dict=feed_dict)

        return emb_array



