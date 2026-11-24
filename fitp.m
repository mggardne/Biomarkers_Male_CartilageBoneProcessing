function [b,p,df,r2,f,r2v,fv] = fitp(x,y,pmx)
%FITP   Computes least squares linear regression for the poynomial
%       model with the highest F value of polynomials with different
%       polynomial orders.
%
%       B = FITP(X,Y) returns the polynomial coefficients of the
%       curvefit with the highest F value for polynomials with
%       polynomial orders between one and five, given the independent X
%       vector and dependent Y vector.
%
%       [B P DF R2 F] = FITP(X,Y) returns the order of the polynomial
%       (P) with the number of regression degrees of freedom (DF),
%       multiple regression correlation coefficient (R2) and F value
%       of the regression (F).
%
%       [B P DF R2 F R2V FV] = FITP(X,Y) returns R2 and F for all
%       polynomial orders in column vectors R2V and FV.
%
%       B = FITP(X,Y,PMX) returns the polynomial coefficients of the
%       polynomial with the highest F value for polynomials with
%       polynomial powers up to PMX.  PMX defaults to five (5).
%
%       05-May-95 * Mack Gardner-Morse
%
%       09-Feb-11 * Mack Gardner-Morse * Let the highest polynomial
%       order be an input parameter.
%
%       08-Apr-11 * Mack Gardner-Morse * Returns R2 and F for all
%       polynomial orders in column vectors.
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<2)
  error('FITP requires two input arguments.');
end
%
if (nargin<3)
  pmx = 5;
end
%
if isempty(pmx)
  pmx = 5;
end
%
% Check that Both Inputs are Vectors
%
[n l] = size(x);
[n2 l2] = size(y);
%
m = min([n l]);
m2 = min([n2 l2]);
%
if ((m~=1)|(m2~=1))
  error('FITP only works with vectors.')
end
%
x = x(:);
y = y(:);
%
[n l] = size(x);
[n2 l2] = size(y);
%
% Check that Both Inputs have the Same Number of Rows
%
if (n~=n2)
  error('X and Y must have the same length.')
end
%
% Least Squares Linear Regression
%
r2v = zeros(pmx,1);
fv = r2v;
%
mf = 0;   % Initial F Value
%
for p = 1:pmx           % Loop through polynomial orders
%
   b = polyfit(x,y,p);
%
% R^2 and F Value Statistics
%
   ybar = mean(y);
   yhat = polyval(b,x);
   dy = y-ybar;
   syy = dy'*dy;
   dr = yhat-ybar;
   ssr = dr'*dr;
   if (syy>eps)
     r2 = ssr/syy;
   else
     r2 = 0;
   end
%
   df = n-p-1;
   de = y-yhat;
   sse = de'*de;
   if (sse>eps)
     f = (ssr/p)/(sse/df);
   else
     f = 0;
   end
%
   r2v(p) = r2;
   fv(p) = f;
%
   if (f>mf)
     mf = f;
     mp = p;
     mr = r2;
   end
end
%
% Least Squares Linear Regression at Maximum F Value
%
b = polyfit(x,y,mp);
p = mp;
df = n-mp-1;
r2 = mr;
f = mf;
%
return