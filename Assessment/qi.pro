;+
; FILENAME:
;    qi.pro
; PURPOSE:
;    ----------
;    Q-Index performance evaluation.
;    
; INPUT:
;    - X          First multispectral image;
;    - Y          Second multispectral image.
;
; OUTPUT:
;    - result     The value of Q-Index (double).
;
; USAGE:
;       ENVI> A = QI(X, Y)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function QI, x, y
  cov_xy = CORRELATE(x, y, /COVARIANCE)
  mean_x = MEAN(x)
  mean_y = MEAN(y)
  var_xy = VARIANCE(x) + VARIANCE(y)
  result = 4.*cov_xy*mean_x*mean_y/((var_xy)*(mean_x^2+mean_y^2))
  RETURN, result
END
