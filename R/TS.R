

# routines to convert time series to rectangular data, so that we can
# then fit using lm() or whatever, predicting from the last lg
# observations

# the first function, TStoX(x,lg,y), inputs a univariate time series and
# outputs an "X" matrix in the sense of lm(Y ~ X); here the "Y" vector
# is either supplied as an argument, or by default is x

# consider for instance x = (5,12,13,8,88,6) and lg = 2, with y = x; we
# want to redict x from itself, i.e.
 
# predict the 13 from 5, 12
# predict the 8 from 12, 13
# predict the 88 from 13, 8
 
# and
 
# predict the 6 from 8, 88

# our training set computed by TStoX() would then be
# 
# X =
# 
#    5 12
#   12 13
#   13  8
#    8 88
#  
# Y = (13,8,88,6)

########################## TStoX() #####################################

# inputs a time series, and transforms to rectangular shape suitable for
# lm() or some other regression model, in which any current observation
# is predicted from the last lg ones

# arguments:
# 
#    x:  a univariate time series; m is set to length(x) below
#    lg:  lag, for fitting of a model in which observations at 
#         time t will be predicted from observations at times 
#         t-lg, t-lg+1,...,t-1
#    y:  if non-NULL, a time series to be predicted, vector of length m; 
#        if y is NULL, y will be taken to be x

# value:
# 
#    matrix, suitable for fitting a prediction model; m-lg rows,
#    lg+1 columns; y[lg+1], y[lg+2], ..., y[m] will be in the last column

#    the "X portion" will be 
#    
#    x[1], x[2], ..., x[lg]
#    x[2], x[3], ..., x[lg+1]
#    ...
#    x[m-lg], x[m-lg+1], ..., x[m-1]

TStoX <- function(x,lg,y=NULL) 
{
   lx <- length(x)
   if (lg >= lx) stop('lg must be < length(x)')
   origlg <- lg
   nColX <- lg + 1  # number of columns in the output "X"
   # the first lxl elements in x will be used in the output "X"
   lxl <- lx - lg 
   mt <- cbind(x[-((lxl+1):lx)],
               1:lxl)
   onerow <- function(mtrow) {
      i <- mtrow[2]
      s <- i
      e <- i + lg - 1
      x[s:e]
   }
   tmp <- t(apply(mt,1,onerow))
   newCol <- if (is.null(y)) x else y
   
   cbind(tmp,newCol[-(1:lg)])
}

# k-variate time series version of TStoX (but y is not optional)

# arguments:

#    each col of xmat is a time series, y is a vector (separate from x)
   
# value:

#    the first k cols will be the k series at lag lg,
#    the second k cols will be the k series at lag lg-1,
#    ...
#    the lg-th k cols will be the k series at lag 1,

TStoXmv <- function(xmat,lg,y) {
   k <- ncol(xmat)
   # take one time series, transform to "X" form, delete the "Y" col
   processOneTS <- function(xmatCol) TStoX(xmatCol,lg)[,1:lg]
   tmp <- lapply(as.data.frame(xmat),processOneTS)
   # now piece everything together
   rslt <- NULL
   for (lag in 1:lg) {
      for (tSer in 1:k) {
         rslt <- cbind(rslt,tmp[[tSer]][,lag])
      }
   }
   cbind(rslt,y[-(1:lg)])

}

