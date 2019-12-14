import subprocess as sp

data_folder = './mtcnnFacesData'
face_net_model = '/Users/xqu/datasets/pretrain/20180402-114759.pb'
output_model = './model/mySVMmodel.pkl'
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
--augment_times {}""".format(data_folder,face_net_model,output_model,batch_size,augment_times)

print("Now runing myclassifer........")
flag=sp.call(cmd,shell=True)
if flag!=0:
    raise Exception('Please check python myclassifier.py cmd ')
else:
    print('\nFinished')
