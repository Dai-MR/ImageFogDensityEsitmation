% Date:20/6/2013
% This code was writen by Changkai Zhao
% Email:changkaizhao1006@gmail.com
% completed and corrected in 20/06/2013 and in 23/06/2013
%
% This algorithm is described in details in 
%
% "Single Image Haze Removal Using Dark Channel Prior",
% by Kaiming He Jian Sun Xiaoou Tang,
% In: CVPR 2009

% details about guilded image filter in
% "Guilded image filtering"
% by Kaiming He Jian Sun Xiaoou Tang

% OUTPUT:J_darkchannel %RA chaged

function [ J_darkchannel] = darkChannel3onlyDark( I,px,w)
 
if (nargin < 3)
   w = 0.95;        % by default, constant parameter w is set to 0.95.
end
if (nargin < 2)
   px = 15;         % by default, the window size is set to 15.
end
if (nargin < 1)
	msg1 = sprintf('%s: Not input.', upper(mfilename));
        eid = sprintf('%s:NoInputArgument',mfilename);
        error(eid,'%s %s',msg1);
end
if ((w >= 1.0) || (w<=0.0))
	msg1 = sprintf('%s: w is out of bound.', upper(mfilename));
        msg2 = 'It must be an float between 0.0 and 1.0';
        eid = sprintf('%s:outOfRangeP',mfilename);
        error(eid,'%s %s',msg1,msg2);
end

if (px < 1)
	msg1 = sprintf('%s: px is out of bound.', upper(mfilename));
        msg2 = 'It must be an integer higher or equal to 1.';
        eid = sprintf('%s:outOfRangeSV',mfilename);
        error(eid,'%s %s',msg1,msg2);
end


% Pick the top 0.1% brightest pixels in the dark channel.
Im=im2double(I);
[dimr,dimc,col]=size(I);
dx=floor(px/2);
% Initial three matrices
J=zeros(dimr,dimc,col);
t_map=zeros(dimr,dimc);
J_darktemp=zeros(dimr,dimc);
tmap_ref=zeros(dimr,dimc);
    if(col==3)
        A_r=0;
        A_g=0;
        A_b=0;
        %% Estimate the atmospheric light (color)
        J_darkchannel=min(Im,[],3);
        for i=(1:dimr)
            for j=(1:dimc)
                ilow=i-dx;ihigh=i+dx;
                jlow=j-dx;jhigh=j+dx;
                if(i-dx<1)
                    ilow=1;
                end
                if(i+dx>dimr)
                    ihigh=dimr;
                end
                if(j-dx<1)
                    jlow=1;
                end
                if(j+dx>dimc)
                    jhigh=dimc;
                end
                J_darktemp(i,j)= min(min(J_darkchannel(ilow:ihigh,jlow:jhigh)));
            end
        end
        J_darkchannel=J_darktemp;
        %%%%cut follow dehazing %%%%%%%%%%%%%%%%%%%%%%%%
    end% col==3
    
    if(col==1)
        Airlight=0;
        %% Estimate the atmospheric light (gray)
        for i=(1:dimr)
            for j=(1:dimc)
                ilow=i-dx;ihigh=i+dx;
                jlow=j-dx;jhigh=j+dx;
                if(i-dx<1)
                    ilow=1;
                end
                if(i+dx>dimr)
                    ihigh=dimr;
                end
                if(j-dx<1)
                    jlow=1;
                end
                if(j+dx>dimc)
                    jhigh=dimc;
                end
                J_darkchannel(i,j)= min(min(Im(ilow:ihigh,jlow:jhigh)));                                      
            end
        end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%cut follow dehazing        
    end
  
end



