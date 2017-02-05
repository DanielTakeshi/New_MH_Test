# Instructions/README

# File Organization

This repository containing materials for our MH test, along with supporting
materials for our various conference submissions.

The most up to date version is in the `icml2017` folder. Compile with `pdflatex
paper.tex` and then `paper arxiv` for the BibTeX in case references have
changed. There are other paper versions in the `paper_versions` directory.
(There is a separate README there.)

Besides that directory, there are two other important directories. The `figures`
directory contains the figures for the LaTeX document, and the `code` directory
contains the scripts. If you need to run experiments, the `code` directory has
what you need.

Any directory that is prefixed with `old` is considered legacy code. You don't
have to worry about it.

# Running the Experiments

The original paper contains two experiments, the Gaussian Mixture Model experiment
and the logistic regression model. To replicate these two experiments that we did
in the paper, follow the instructions below.

- `code/gaussianMixtureModel.ssc`
- `code/logisticRegressionModel.ssc`

(To be extra clear, the `logisticRegressionModel.ssc` script contains an example of an exact
statement that you can run on the command line, and it also contains a considerable amount of 
documentation within it.)

The first script runs a mixture of Gaussians process from the Stochastic Gradient Langevin Dynamics
paper, by Max Welling et al., ICML 2011.  The second script runs logistic regression on the binary
classification task of MNIST 1s vs 7s, but we actually use MNIST-8M, a larger version.

There are multiple versions of the MNIST-8M dataset we used, with different sizes (we were running
out of memory with the larger sizes). All of them are stored in bitter under my home directory (and
probably in Xinlei's as well). The logistic regression script uses absolute paths so it should be
reachable from anywhere.

#### Step-by-step guide to run gaussian mixture model experiment

##### Data preparation

1. Generate `norm2log%d_20_%2.1f.txt` file using `genNormToLog.ssc`. Be sure to
specify the value of sigma and N at the first and second line of
`genNormToLog.ssc`. We use sigma = 0.9 and N = 2000 here for example. After
running this, there will be a file named `norm2log2000_20_0.9.txt` under the
folder "code". 

(1) Change sigma = 0.9, N = 2000 in `genNormToLog.ssc` in the first 2 lines.

(2) Run `$ BIDMach/bidmach genNormToLog.ssc`

For replicating the exact results in the paper, you may need to use the file we
generated here in the github.

2. Generate the gaussian data file using `gaussianDataGeneration.ssc`. Be sure
to specify the parameters at the first part of `gaussianDataGeneration.ssc`,
where sigma is the standard error of sample x, n is the number of samples,
theta1 together with theta2 is the model mode. This will generate a file named
`gaussianPureData.mat` file under the folder `code`.

(1) Set sigma to math.sqrt(2), n to 1000000, theta1 to 0.0 and theta2 to 1.0.

(2) Run: `$ BIDMach/bidmach gaussianDataGeneration.ssc`.

##### Run the test

3. Run `gaussianMixtureModel.ssc`. Be sure to specify the parameters at the last
part of this code, where nsamps is the number of MCMC sampling, n is the number
of data points, sigma is the standard error of sample data point, batchsize is
the minibatch size, sigma_proposer is the standard error of random walk
proposer. After running this file, a file named `gaussiandata.mat` which
contains the samples of theta, likelihood of the data from our method, cutmh
method, and the adaptivemh method.

`scala> :load gaussianMixtureModel.ssc`

### Plotting and Analyzing

To plot and analyze the results, you need to use the `.mat` files which are created by the scripts
above and contain information about the samples themselves, the log likelihood values, etc. (Our
scripts should adjust the names of these output files automatically based on various parameter
settings, but it never hurts to double check the names.) We used Jupyter Notebooks to form the plots
in the paper:

- `code/plot_result_GaussianMixtureModel.ipynb`
- `code/plot_result_logisticRegression.ipynb`

Feel free to adjust these as needed (they're a bit rough). Be careful not to override figures when
running cells; I find it best to have Jupyter Notebooks save to a *draft* figures folder, and then
we copy the final version of the figures over to the official `figures` directory.

#### Data required for "plot_result_GaussianMixtureModel.ipynb"

The dataset required for running this notebook are `gaussiandata.mat` and
`log_posterior.mat`. You can download `log_posterior.mat` from here:
https://www.dropbox.com/s/vguodsuk0dnu0wb/log_posterior.mat?dl=0
