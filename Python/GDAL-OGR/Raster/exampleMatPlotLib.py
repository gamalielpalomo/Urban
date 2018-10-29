"""import matplotlib.pyplot as plt
plt.plot([1,2,3,4])
plt.ylabel('some numbers')
plt.show()
plt.colorbar()"""

import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import numpy as numpy
img = mpimg.imread('cinves-logo.png')
imgplot = plt.imshow(img)
plt.show()