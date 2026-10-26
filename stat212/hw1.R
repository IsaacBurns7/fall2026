getwd()
#PROBLEM 5
df <- read.table("BacteriaDeath.txt", header = TRUE)
t <- df[, 1]
y <- df[, 2]
##part a
par(mfrow = c(1, 2))
plot(t, y,      main = "y vs t",      xlab = "t", ylab = "y")
plot(t, log(y), main = "log(y) vs t", xlab = "t", ylab = "log(y)")
#the plot of log(y) vs t suggests a linear relationship 

##part b
fit <- lm(log(y) ~ t)
print(summary(fit))
print(coef(fit))
b0 <- coef(fit)[1]   # estimate of log(beta0)
b1 <- coef(fit)[2]   # estimate of b1 
abline(fit, col = "red")   # overlay the fit on the log(y) vs t plot

plot(t, y)  #plot y vs t
curve(exp(b0) * exp(b1 * x), add = TRUE, col = "red") #overlay fit on y vs t plot
  #original mu_{y|x} = alpha0 * e^{b_1*t}, alpha0 = e^{b0}, x = t
predict_y <- function(tt) exp(b0 + b1 * tt)
print(predict_y(5))   # prediction at t = 5
print(predict_y(25))  # prediction at t = 25

#PROBLEM 6
df <- read.table("WindSpeed.txt", header = TRUE)
output <- df[, 1]
windspeed <- df[, 2]
##part a
par(mfrow = c(1,2))
plot(windspeed, output, main = "output vs windspeed", xlab = "windspeed(mph)", ylab = "output")
plot(1/windspeed, output, main = "output vs 1/windspeed", xlab = "1/windspeed(mph)", ylab = "output")
#the plot of output vs 1/windspeed suggests a linear relationship

##part b for problem A2 
fit <- lm(output ~ I(1/windspeed))
print(summary(fit))
print(coef(fit))
b0 <- coef(fit)[1] # estimate of log(beta0) 
b1 <- coef(fit)[2] # estimate of b1

##problem B1 
abline(fit, col = "red") 

plot(windspeed, output)
curve(b0 + b1/x, add = TRUE, col = "red") #overlay fit on output vs windspeed plot
  #original mu_{y|x} = beta0 + b1/x, since y is not transformed, we use this as the equation
predict_y <- function(tt) b0 + b1 / tt
print(predict_y(4)) #prediction at wind speed 4
print(predict_y(25)) #prediction at wind speed 25

##part c for problem A2 
print(predict_y(8)) #requested prediction at wind speed of 8 mph

##problem B2- plots of the residuals...
#ei vs xi 
#ei vs yi_hat
resid = fit$residuals
predict = fit$fitted.values
plot(I(1/windspeed), resid, xlab = "x", ylab = "Residuals")
plot(predict, resid, xlab = "yhat", ylab = "Residuals")
#the residuals seem to cluster around 0.10, when x = 0.10, and yhat = 2.5...clea

#Histogram, Kernel Density Estimate, and Normal Quantile Plot of residuals (check normality assumption)
hist(resid)
plot(density(resid))
qqnorm(resid)
#the residuals histogram and density plot seem to suggest that
  #the residuals are largely normal, but skewed to the right slightly... 

##problem B3
r2 = cor.test(windspeed,output)
print(r2)
  # gives 0.9351434, with a 95% CI of [0.8564885, 0.9713548]
  # therefore, it is very likely the two are strongly correlated 
##problem B4
print(confint(fit, 2, level = 0.99)) #2 = I(1/windspeed)
  #gives [-7.514076, -6.355019]
##problem B5 
print(predict(fit, newdata = data.frame(windspeed = 3.2),
        interval = "confidence", level = 0.95))#interval is [lwr, upr]
  #uses (b0_hat + b1_hat * x_0) +- t_{n-2;alpha/2} * SE(x0)
##problem B6
print(predict(fit, newdata = data.frame(windspeed = 9.05),
        interval = "prediction", level = 0.95)) #interval is [lwr, upr]
  #uses (b0_hat + b1_hat * x_0) +- t_{n-2;alpha/2} * SE_pred(x0)