"""
Test SMF.scala on the first iteration of Netflix, with MHTest updater only. NO
INTERNAL ADAGRAD UPDATER.

File name convention:

accept{false,some,true} for always rejecting, normal update rule, and always
accepting, respectively, in MHTest. We SHOULD be using the `some` (i.e. normal
update rule) in practice.

{no,yes}updates, for commenting out, or not, respectively, the two lines in the
mupdate method which update the two bias model matrices.

log_acceptfalse_noupdates.txt  
log_acceptfalse_yesupdates.txt
log_acceptsome_noupdates.txt   
log_acceptsome_yesupdates.txt
log_accepttrue_noupdates.txt   
log_accepttrue_yesupdates.txt
"""


import numpy as np
import matplotlib.pyplot as plt
plt.style.use('seaborn-darkgrid')
plt.figure(figsize=(11,8))
plt.plot(np.loadtxt("log_acceptfalse_noupdates.txt"),  'k-',  lw=4, label="False/No")
plt.plot(np.loadtxt("log_acceptfalse_yesupdates.txt"), 'k--', lw=4, label="False/Yes")
plt.plot(np.loadtxt("log_acceptsome_noupdates.txt"),   'y-',  lw=4, label="Some/No")
plt.plot(np.loadtxt("log_acceptsome_yesupdates.txt"),  'y--', lw=4, label="Some/Yes")
plt.plot(np.loadtxt("log_accepttrue_noupdates.txt"),   'b-',  lw=4, label="True/No")
plt.plot(np.loadtxt("log_accepttrue_yesupdates.txt"),  'b--', lw=4, label="True/Yes")
plt.legend(loc=(0.0,0.2))
plt.savefig("rmse_smf.png")
