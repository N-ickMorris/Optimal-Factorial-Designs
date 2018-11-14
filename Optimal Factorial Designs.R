# install packages
# install.packages("data.table")
# install.packages("AlgDesign")

# load packages
require(data.table)
require(AlgDesign)

# we have 7 parameters of interest:
  # nrounds ~ the max number of boosting iterations
  # eta ~ the learning rate
  # max_depth ~ maximum depth of a tree
  # min_child_weight ~ minimum sum of instance weight needed in a child
  # subsample ~ the proportion of data (rows) to randomly sample each round
  # colsample_bytree ~ the proportion of variables (columns) to randomly sample each round
  # gamma ~ minimum loss reduction required to make a further partition on a leaf node of the tree

# create parameter combinations to test
doe = data.table(expand.grid(nrounds = c(100, 500),
                             eta = c(0.01, 0.015, 0.025, 0.05, 0.1),
                             max_depth = c(3, 5, 7, 9, 12, 15, 17, 25), 
                             min_child_weight = c(1, 3, 5, 7),
                             subsample = c(0.6, 0.8, 1),
                             colsample_bytree = c(0.6, 0.8, 1),
                             gamma = c(0.05, 0.1, 0.3, 0.5, 0.7, 0.9, 1)))

# lets get a smaller optimal design from doe
# compute the number of levels for each variable in our design
levels.design2 = sapply(1:ncol(doe), function(j) length(table(doe[, j, with = FALSE])))

# build the general factorial design
doe.gen = gen.factorial(levels.design)

# compute a smaller optimal design
set.seed(42)
doe.opt = optFederov(data = doe.gen, 
                     nTrials = 5000)

# update which rows to keep in doe according to doe.opt
doe = doe[doe.opt$rows]

# set up model IDs
# make a copy of doe
mod.id = data.table(doe)

# give mod.id an id column
mod.id[, mod := 1:nrow(mod.id)]

# export mod.id
write.csv(mod.id, "gbm-model-ID-numbers.csv", row.names = FALSE)
