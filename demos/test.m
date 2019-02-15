img_path = '2010_005731.png'
img = imread(img_path)
resize_img = imresize(img, 0.5)
imshow(resize_img)