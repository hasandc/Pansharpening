;+
; FILENAME:
;    upsampling.pro
; PURPOSE:
;    ----------
;    To resize a MS image up by a ratio.
; INPUT:
;    - i_origin       A reference image;
;    - RATIO          Scalling ratio - the value should be at the power of two.
;
; KEYWORD PARAMETERS:
;   BICUBIC: If this keyword is set, a Bicubic interpolation is used for the upscalling. 
;   Otherwise, the upsizing will use a general polynomial interpolation method.
;
; OUTPUT:
;    - i_interp      An interpolated image.
;
; USAGE:
;       ENVI> A = UPSAMPLING(i_origin, ratio[, /BICUBIC])
;
; REVISION HISTORY:
;    2019-Sept-30  H.Cahyono
;                  Initial coding.
;-

function UPSAMPLING, i_origin, ratio, BICUBIC=isBicubic
  dim_i = SIZE(i_origin)
  i_pre_interp = i_origin

  if (N_ELEMENTS(isBicubic) OR ARG_PRESENT(isBicubic)) then begin
    case dim_i[0] of
      2: begin
        i_interp = CONGRID(i_pre_interp, dim_i[1]*ratio, $
          dim_i[2]*ratio, /CENTER, CUBIC=-0.5, /INTERP)
      end
      3: begin
        i_interp = MAKE_ARRAY(dim_i[1]*ratio, dim_i[2]*ratio, dim_i[3], value=0.0, /DOUBLE)
        for i=0, dim_i[3]-1 do begin
          i_interp[*, *, i] = CONGRID(i_pre_interp[*, *, i], dim_i[1]*ratio, $
            dim_i[2]*ratio, /CENTER, CUBIC=-0.5, /INTERP)
        endfor
      end
      else: begin
        print, 'The image should be 2 or 3 dimensions to perform Bicubic Interpolation.'
        i_interp = [0*REPLICATE(0, dim_i[0])]
      end
    endcase
  endif else begin
    i_interp = POLINTERP_GENERAL(i_pre_interp, ratio)
  endelse
  RETURN, i_interp
end
