;+
; FILENAME:
;    mtf.pro
; PURPOSE:
;    ----------
;    This function is used to perform MTF filtering on a reference image (2-D).
;    Gaussian filtering is used with some variable adjustments.
;    
; INPUT:
;    - IMG            A 2-dimensional image data;
;    - NYQ            The Nyquist frequency;
;    - NTERMS         The number of filters MTF;
;    - RATIO          Scalling ratio.
;
; OUTPUT:
;    - i_result       A filtered imaged.
;
; USAGE:
;       A = MTF(img, nyq, nterms, ratio)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.

function MTF, img, Nyq, nterms, ratio
  fcut = 1./ratio

  sigma = SQRT((nterms*(fcut/2.))^2)/(-2.*ALOG(Nyq))
  i_result = GAUSS_SMOOTH(img, sigma, /EDGE_MIRROR, WIDTH=nterms)
  RETURN, i_result
end