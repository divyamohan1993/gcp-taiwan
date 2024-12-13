# -*- coding: utf-8 -*-
import requests
# Change the value of experience that you want to test
url = 'https://iris-predict-dot-mygcp-436602.de.r.appspot.com/api'   # 改成 127.0.0.1
feature = [[5.8, 4.0, 1.2, 0.2]]
labels ={
  0: "setosa",
  1: "versicolor",
  2: "virginica"
}

r = requests.post(url,json={'feature': feature})
print(labels[r.json()])