;+
; FILENAME:
;    pca_fus.pro
; PURPOSE:
;    ----------
;    To perform principal component analysis (PCA) based fusion using a multiband MS and panchromatic images.
; INPUT:
;    - I_MS           A 3-dimensional image data;
;    - I_PAN          Image data of 2-dimensions;
;
; KEYWORD PARAMETERS:
;   EQUALIZATION: If set, causes a linear equalization to be used before performing a filtering.
;       Otherwise, a MTF filtering is performed.
;
;   FUSION: If set, a fusion of MS and filtered PAN is returned.
;       Otherwise, a standard MTF filtering image is performed.
;
; OUTPUT:
;    - i_ms_transformed A transformed MS Image using PCA. 
;
; USAGE:
;       ENVI> A = PCA_FUS(I_MS, I_PAN[, /EQUALIZATION, /FUSION])
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function PCA_FUS, i_ms, i_pan, FUSION=fus, EQUALIZATION=equal
  clock = TIC('PCA_FUS')
  dim_ms = SIZE(i_ms)
  ims_bands = REFORM(i_ms, dim_ms[1]*dim_ms[2], dim_ms[3])
  bands = MAKE_ARRAY(dim_ms[1]*dim_ms[2], dim_ms[3], value=0.0, /DOUBLE)

  ; mean substraction for each band
  for i=0, dim_ms[3]-1 do begin
    bands[*, i] = ims_bands[*, i] - MEAN(ims_bands[*, i])
  endfor

  ; construct the Y matrix
  Y = TRANSPOSE(bands)/SQRT(dim_ms[3]-1)

  ; using the Y matrix to get the principal component (Vsvd)
  LA_SVD, Y, sigma, Usvd, Vsvd

  ; project the Multispectral Image data
  i_ms_transformed = TRANSPOSE(Vsvd) ## bands
  ipan_centered = REFORM(i_pan, dim_ms[1]*dim_ms[2])

  ; do an equalization
  if (N_ELEMENTS(equal) OR ARG_PRESENT(equal)) then $
    ipan_centered = EQUALIZE(i_ms_transformed[*, 0], ipan_centered)

  ; do an injection of PAN image to the 1st band of the projected MS Image
  if (N_ELEMENTS(fus) OR ARG_PRESENT(fus)) then $
    i_ms_transformed[*, 0] = ipan_centered

  ; do an inversion of pca
  i_ms_transformed = Vsvd ## i_ms_transformed

  ; transform the existing 3-dimensional Multispectral image into 2 dimensions.
  i_ms_reformed = REFORM(i_ms, dim_ms[1]*dim_ms[2], dim_ms[3])

  ; final linear equalisation
  for i=0, dim_ms[3]-1 do begin
    h = i_ms_transformed[*, i]
    i_ms_transformed[*, i] = h - MEAN(h) + MEAN(DOUBLE(i_ms_reformed[*, i]))
  endfor

  ; retransform the multispectral image back to its original size (3 Dimensions)
  i_ms_transformed = REFORM(i_ms_transformed, dim_ms[1], dim_ms[2], dim_ms[3])
  TOC, clock
  RETURN, i_ms_transformed
end
