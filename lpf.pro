;+
; FILENAME:
;    lpf.pro
; PURPOSE:
;    ----------
;    To perform a low-pass filtering of an image. A 3x3 kernel size is used on a centered and  
;    edge-truncated CONVOL command. This function is not yet tested. However, this function is   
;    working as a low-pass filtering should based on Gaussian Smoothing.
;
; INPUT:
;    - IMG                  A source image;
;    - SIGMA                The standard deviasion value to be used for the Gaussian Smoothing;
;    - NTERM                The number of filters for Gaussian Smooting.
;
; OUTPUT:
;    - image                An imaging data from a selected file (2-D or 3-D).
;
; USAGE:
;       ENVI> A = LPF(IMG, SIGMA, NTERMS)
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function LPF, img, sigma, nterms
  ; Create a low pass filter.
  kernelSize = [3, 3]
  kernel = REPLICATE((1./(kernelSize[0]*kernelSize[1])), $
    kernelSize[0], kernelSize[1])

  ; Apply the filter to the image.
  filteredImage = CONVOL(FLOAT(croppedImage), kernel, $
    /CENTER, /EDGE_TRUNCATE)

  ; Apply the filter to the image.
  filteredImage = GAUSS_SMOOTH(img, sigma, /EDGE_MIRROR, WIDTH=nterms)

  RETURN, filteredImage
end