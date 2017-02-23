For the ones with "D1" in them, those are for the conservative test with mu_std
each iteration. The matlab files store two matrices:

result_error
result_meanj

With the obvious naming convention. First axis in each is for the epsilons, the
second is for the minibatch sizes. I used:

epsilons = [0.001, 0.005, 0.01, 0.05, 0.1, 0.2];
sizes = [50, 100, 150, 200, 250, 300, 350, 400, 450, 500];

So the matrices should be (6,10). In BIDMach I can load them as:

scala> val a:DMat = load("MATLAB_files/mu_std_K10_D1_mnist.mat", "result_error")
a: BIDMat.DMat =
  0.031258  0.025380  0.022334  0.019729  0.017977  0.017198  0.016237  0.014892  0.013680  0.012836
  0.11400   0.095591  0.085945  0.077058  0.071121  0.068988  0.065894  0.060773  0.056170  0.053069
  0.18735   0.16060   0.14633   0.13258   0.12337   0.12047   0.11581   0.10731   0.099666  0.094580
  0.43297   0.40626   0.38950   0.37013   0.35615   0.35311   0.34632   0.33020   0.31495   0.30469
  0.49243   0.48470   0.47841   0.46970   0.46248   0.46089   0.45705   0.44705   0.43657   0.42902
  0.49999   0.49994   0.49984   0.49960   0.49928   0.49916   0.49889   0.49813   0.49704   0.49604

scala> val b:DMat = load("MATLAB_files/mu_std_K10_D1_mnist.mat", "result_meanj")
b: BIDMat.DMat =
  251.35  126.49  84.954  63.638  51.008  43.215  37.366 32.489  28.582  25.648
  226.83  116.18  78.812  59.474  47.931  40.754  35.354 30.850  27.231  24.498
  203.06  105.92  72.586  55.196  44.736  38.178  33.234 29.110  25.784  23.260
  94.586  55.730  40.903  32.717  27.534  24.097  21.465 19.273  17.466  16.045
  37.260  25.563  20.425  17.358  15.287  13.815 12.660  11.693  10.876  10.205
  6.1591  5.6047  5.2510  4.9892  4.7812  4.6096 4.4629  4.3340  4.2188  4.1158

Here, the rows represent epsilons, going from 0.001 at the top row to 0.2 at the
bottom. The sizes are similar except they're across columns.


The others with "D4000" in them are for the slower test which has to recompute
mu_std each iteration.
