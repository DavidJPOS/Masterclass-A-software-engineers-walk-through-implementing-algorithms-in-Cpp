#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]

#include <sstream>
#include <string>
#include <vector>

using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp 
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//


template<class Mat>
void stop_if_has_nan_or_inf(const Mat& input, const std::string& name)
{
  if(input.has_nan() or input.has_inf())
  {
    stop(name + " must not contain NaN or Inf");
  }
}

void validate_vector(const arma::vec& input,
                     const std::string& name,
                     const std::size_t expected_length)
{
  if(input.n_elem != expected_length)
  {
    std::ostringstream error_message{name};
    error_message << " must be a column vector of length " << expected_length;
    stop(error_message.str());
  }
  stop_if_has_nan_or_inf(input, name);
}

void validate_matrix(const arma::mat& input,
                     const std::string& name,
                     const arma::SizeMat& expected_size)
{
  if(arma::size(input) != expected_size)
  {
    std::ostringstream error_message{name};
    error_message << " must be a " 
                  << expected_size.n_rows << "x" << expected_size.n_cols
                  << " matrix";
    stop(error_message.str());
  }
  stop_if_has_nan_or_inf(input, name);
}

void validate_covariance_matrix(const arma::mat& input,
                                const std::string& name,
                                const arma::SizeMat& expected_size)
{
  validate_matrix(input, name, expected_size);
  if(arma::any(input.diag() < 0.0))
  {
    stop("main diagonal of P must be greater than or equal to zero");
  }
}

class KalmanFilter
{
public:
  KalmanFilter(std::size_t x_dim, std::size_t z_dim)
    : _x_dim{x_dim}
  , _z_dim{z_dim}
  {
    if(x_dim == 0 or z_dim == 0)
    {
      stop("x_dim and z_dim must be greater than zero");
    }
    _x = arma::zeros(x_dim);
    _P = arma::eye(_x_dim, _x_dim);
    _F = arma::eye(_x_dim, _x_dim);
    _Q = arma::zeros(_x_dim, _x_dim);
    _H = arma::eye(_z_dim, _x_dim);
    _R = arma::zeros(_z_dim, _z_dim);
  }
  
  void initialiseEstimate(arma::vec x, arma::mat P)
  {
    validate_vector(x, "x", _x_dim);
    validate_covariance_matrix(P, "P", arma::size(P));
    _x = x;
    _P = P;
  }
  
  void setProcessModel(arma::mat F, arma::mat Q)
  {
    validate_matrix(F, "F", arma::size(_F));
    validate_covariance_matrix(Q, "Q", arma::size(_Q));
    _F = F;
    _Q = Q;
  }
  
  void setMeasurementModel(arma::mat H, arma::mat R)
  {
    validate_matrix(H, "H", arma::size(_H));
    validate_covariance_matrix(R, "R", arma::size(_R));
    _H = H;
    _R = R;
  }
  
  List predict()
  {
    arma::vec x_pred = _F * _x;
    arma::mat P_pred = _F * _P * _F.t() + _Q;
    _x = x_pred;
    _P = P_pred;
    return List::create(Named("prior") = x_pred,
                        Named("prior_covariance") = P_pred);
  }
  
  List update(const arma::vec& z)
  {
    validate_vector(z, "z", _z_dim);
    arma::vec y = z - _H * _x;
    arma::mat S = _H * _P * _H.t() + _R;
    arma::mat K = _P * _H.t() * S.i();
    arma::vec x_post = _x + K * y;
    // arma::mat m_K = arma::eye(K.n_rows, _H.n_cols) - K * _H;
    // arma::mat P_post = m_K * _P * m_K.t() + K * _R * K.t();
    arma::mat P_post = _P - K * _H * _P;
    _x = x_post;
    _P = P_post;
    return List::create(Named("residual") = y,
                        Named("posterior") = x_post,
                        Named("posterior_covariance") = P_post);
  }
  
private:
  std::size_t _x_dim; // std::size_t is the type for storing sizes.
  
  std::size_t _z_dim;
  
  arma::vec _x;
  
  arma::mat _P;
  
  arma::mat _F;
  
  arma::mat _Q;
  
  arma::mat _H;
  
  arma::mat _R;
};

RCPP_MODULE(kalman_filter)
{
  class_<KalmanFilter>("KalmanFilter")
  .constructor<std::size_t, std::size_t>()
  .method("initialiseEstimate", &KalmanFilter::initialiseEstimate)
  .method("setProcessModel", &KalmanFilter::setProcessModel)
  .method("setMeasurementModel", &KalmanFilter::setMeasurementModel)
  .method("predict", &KalmanFilter::predict)
  .method("update", &KalmanFilter::update)
  ;
}

// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R

*/