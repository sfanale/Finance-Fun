function [m, b, sigma_m, sigma_b, chi_squared_reduced, r2] = LinFit(x,y,sigma)

sigma2 = 1./( sigma.*sigma );
N = length(x);

Delta = sum( sigma2 ) * sum( x.*x.*sigma2) - ( sum( x.*sigma2 ) )^2;
m = (1/Delta) * ( sum( sigma2 ) * sum( x.*y.*sigma2 ) - sum( x.*sigma2 ) * sum( y.*sigma2 ) );
b = (1/Delta) * ( sum( x.*x.*sigma2 ) * sum( y.*sigma2 ) - sum( x.*sigma2 ) * sum( x.*y.*sigma2 ) );

sigma_m = sqrt( sum( sigma2 ) / Delta );
sigma_b = sqrt( sum( x.*x.*sigma2 ) / Delta);

residual = y - m*x - b;

chi_squared_reduced = sum( residual.*residual.*sigma2 ) / ( N - 2 );

ybar = mean(y);
numerator_vector = m * x  +b - ybar ;
denominator_vector = y - ybar;
numerator = sum( numerator_vector.*numerator_vector );
denominator = sum( denominator_vector.*denominator_vector );
r2 = numerator / denominator;

end
