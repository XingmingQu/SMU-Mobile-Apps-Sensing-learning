# -*- coding:utf-8 -*-  
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

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

import math
import pickle
from sklearn.svm import SVC



#--------------Argument------------------------------------------------
modeldir='/Users/xqu/datasets/pretrain/20180402-114759.pb'
classifier_filename_exp='/Users/xqu/datasets/mymodels/lfw_classifier.pkl'
FaceImW=160
FaceImH=160
WindowWidth=600
WindowHight=400
interval=10
MAXface=20

#----------------------------------------------------------------------


def main():
    i = 0
    with tf.Graph().as_default():
        gpu_options = tf.compat.v1.GPUOptions(per_process_gpu_memory_fraction=0)
        sess = tf.compat.v1.Session(config=tf.compat.v1.ConfigProto(gpu_options=gpu_options, log_device_placement=False))
        with sess.as_default():
            pnet, rnet, onet = align.detect_face.create_mtcnn(sess, None)
    minsize = 20 # minimum size of face
    threshold = [ 0.6, 0.7, 0.7 ]  # three steps's threshold
    factor = 0.709 # scale factor

#-------------set Video-----------------------------

    #cap = cv2.VideoCapture('/home/razer/Documents/facenet/facenet/src/align/1.mpg')
    cap = cv2.VideoCapture(0)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH,WindowWidth)  
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT,WindowHight) 
    # cap.set(cv2.CAP_PROP_FPS,20) 
    # ft=cap.get(cv2.CAP_PROP_FPS)

#--------------------------------------------------------

    with tf.Graph().as_default():
        with tf.Session() as sess:
            print('\n\n----Loading feature extraction model----')
            facenet.load_model(modeldir)
            print('\nFinish Loading feature extraction model----')

            # Get input and output tensors
            images_placeholder = tf.get_default_graph().get_tensor_by_name("input:0")
            embeddings = tf.get_default_graph().get_tensor_by_name("embeddings:0")
            phase_train_placeholder = tf.get_default_graph().get_tensor_by_name("phase_train:0")
            embedding_size = embeddings.get_shape()[1]

            # Run forward pass to calculate embeddings
            print('Calculating features for images')

            print('\nTesting classifier\n')
            with open(classifier_filename_exp, 'rb') as infile:
                (model, class_names) = pickle.load(infile)
            print('Loaded classifier model from file "%s"' % classifier_filename_exp)

            # x=0
            # Pdata=[str(x) for x in range(MAXface)]
            while(cap.isOpened()):

                # if x%interval==0:
                #     find_results=[]

                ret, frame = cap.read()
                img=frame

                bounding_boxes, _ = align.detect_face.detect_face(img, minsize, pnet, rnet, onet, threshold, factor)
                nrof_faces = bounding_boxes.shape[0]

                if nrof_faces > 1:
                	print('multiple faces detected...please show one face at a time')
                else:
	                for face_position in bounding_boxes:
	                    face_position=face_position.astype(int)

	                    crop=img[face_position[1]:face_position[3],face_position[0]:face_position[2],]
	                    #crop = cv2.resize(crop, (FaceImW, FaceImH), interpolation=cv2.INTER_CUBIC )
	                    #print ('crop',crop.shape)
	                    try:
	                    	# scaled = misc.imresize(crop, (FaceImW, FaceImH), interp='bilinear')
	                        scaled = cv2.resize(crop, (FaceImW, FaceImH))
	                    except:
	                    	print ('Face angle is not good, please face the camera..')
	                    	#find_results.append('Can not find face.\nPlease face to camera...')
	                    	continue
	                    #print ('scaled',scaled.shape)
	                    #cv2.FaceImWrite('/home/razer/Pictures/face/'+str(a)+'1_'+'.jpg', scaled)
	                   
	                    images = np.zeros((1, FaceImW, FaceImH, 3))

	                    if scaled.ndim == 2:
	                        scaled = facenet.to_rgb(scaled)
	                   
	                    scaled = facenet.prewhiten(scaled)

	                    images[0,:,:,:]=scaled
	                    #print ('images',images.shape)

	                    cv2.rectangle(frame, (face_position[0], 
	                                face_position[1]), 
	                          (face_position[2], face_position[3]), 
	                          (0, 255, 0), 2)           
	                  
	                    #print (images.shape)

	                    #predictions part---------------------------------------------------------------------                    #print (images.shape)

	                    feed_dict = { images_placeholder:images, phase_train_placeholder:False }
	                    emb_array = sess.run(embeddings, feed_dict=feed_dict)
	                    
	                    predictions = model.predict_proba(emb_array)
	                    
	                    best_class_indices = np.argmax(predictions, axis=1)
	                    print(best_class_indices[0])
	                    sig_test = list(predictions[0])
	                    # del sig_test[best_class_indices[0]]
	                    
	                    arrstd = np.std(sig_test)
	                    arrmean = np.mean(sig_test)
	                    left = arrmean-4*arrstd
	                    right = arrmean+4*arrstd
	                    print(arrmean,arrstd)
	                    print(right)

	                    best_class_probabilities = predictions[np.arange(len(best_class_indices)), best_class_indices]
	                    print (best_class_probabilities)
	                    if best_class_probabilities[0] > 0.5 and right < best_class_probabilities[0]:

		                    pre=float(best_class_probabilities[i])*100
		                    pre= round(pre,2)
		                    pre=str(pre)+'%'

		                    
		                    a=class_names[best_class_indices[i]].split(' ')
		                    result=a[0]
		                    # print(a)
		                    #find_results.append(result+' '+p)

		                    cv2.putText(frame,'{}'.format(result+' '+pre), (face_position[0], 
		                                face_position[1]-15), 
		                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255 ,0), 
		                    thickness = 2, lineType = 1)  
	                    else:
		                    cv2.putText(frame,'{}'.format('UNKNOWN'), (face_position[0], 
		                                face_position[1]-15), 
		                    cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255 ,0), 
		                    thickness = 2, lineType = 1)  		                	
           

	                # x=x+1

	                     #predictions--- end ---------------------------------------------------------------------

                cv2.imshow('frame',frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

            cap.release()              
            cv2.destroyAllWindows()


if __name__ == '__main__':
    main()