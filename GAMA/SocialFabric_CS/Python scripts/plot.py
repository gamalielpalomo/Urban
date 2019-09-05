import numpy as np
import matplotlib.pyplot as plt

data = [[383.00166666666667,
342.23333333333335,
339.5183333333333,
423.0,
352.4266666666667,
366.845,
381.21666666666664,
328.14666666666665,
390.79,
343.585],
		[404.72,
293.27666666666664,
358.97833333333335,
322.04,
403.49,
352.52,
309.61,
374.2866666666667,
329.94,
294.54333333333335]]	
fig1, ax1 = plt.subplots()
ax1.set_title('Encounters between social agents')
ax1.boxplot(data,notch=True,labels=["without perception","with perception"])
plt.show()