%%%
% =========================================================================
%  Find_beads_auto_LAM.m  
%  Copyright © 2023-2025 Lauren McCarthy (Univerisy of Michigan)
%  SPDX-License-Identifier: GPL-3.0-or-later
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program (LICENSE file in the repository root).
%  If not, see <https://www.gnu.org/licenses/>.
%
% =========================================================================
%%%
function fit_crds=Find_beads_auto_LAM(fname,sublen,fitboxSize,sname,pdsz,MinNum)
% Find_beads is a function to locate fluoresbrite beads in a movie using PSF fitting. It
% returns the pixel locations of the bead and adjusts your single molecule
% fits based off of the movement of the bead

% If there is a bad fit:you will be notified in the command window with a
% warning

%%%% Inputs %%%%
% fitboxSize is the side length of a box which will be used to fit the bead emission profile,
% needs to be odd
%
%%% Output %%%%
% drift corrected fits file

%%%% Dependencies %%%%
% gaussfit (from DJR)



%create A `TIFFStack` object  which behaves like a read-only memory
matio=matfile(fname);
info=whos(matio,'mov');
movsz=info.size;
ROIShow=zeros(movsz(1),movsz(2));

for i=1:10 %since we are just getting the relative coordinates of the bead, we can speed through this step by only averaging the first 10 frames
data=double(matio.mov(:,:,i));
ROIShow=ROIShow+data;
end

ROIShow=ROIShow/10;
ROIShow=padarray(ROIShow,[pdsz,pdsz],'symmetric');%pad it

figure;
ROItxtin = 110; %110 is the ASCII code for the letter n
while (ROItxtin ~= 121 || isempty(ROItxtin)) %while ROItxtin does not equal (~=) 121 (which is y) or ROI txtin is empty - || evaluates only if need be
    imshow(ROIShow,[])
    % Click and choose fiduciaries ginput returns
    ROIcents = round(ginput);
    
    numROIs = size(ROIcents, 1);
    hold on
    for jj=1:numROIs
        pxb_x=ROIcents(jj,1)+[-(fitboxSize-1)/2,(fitboxSize-1)/2];
        pxb_y=ROIcents(jj,2)+[-(fitboxSize-1)/2,(fitboxSize-1)/2];
        
        plot(pxb_x(1):pxb_x(2),repmat(pxb_y(1),[1,pxb_x(2)-pxb_x(1)+1]),'r','LineWidth',2)%upper edge
        plot(pxb_x(1):pxb_x(2),repmat(pxb_y(2),[1,pxb_x(2)-pxb_x(1)+1]),'r','LineWidth',2)%lower edge
        plot(repmat(pxb_x(1),[1,pxb_y(2)-pxb_y(1)+1]),pxb_y(1):pxb_y(2),'r','LineWidth',2)%right edge
        plot(repmat(pxb_x(2),[1,pxb_y(2)-pxb_y(1)+1]),pxb_y(1):pxb_y(2),'r','LineWidth',2)%left edge
        
        text(ROIcents(jj,1)-(fitboxSize+1),ROIcents(jj,2)+(fitboxSize+1),num2str(jj),'color','red','fontsize',13,'fontweight','bold');
    end
    hold off
    ROItxtin=input('Does this ROI selection look OK to you (y/n)?  ','s');
end
ROIs=ROIcents;



%% Fit the beads for each sublen and create an avgmov variable with the average frames from every sublen
fit_crds=NaN(1,numROIs,floor(movsz(3)/sublen),2);
%change the first array value in the line above ("1") if you would like to
%edit this code to process more than one movie at a time. As written, it is
%intended to only process one movie at a time
    mov=matio.mov; %this step takes a while but is the best way I could find to do it
    mov=double(mov);
    bxsz=fitboxSize;
    avgmov=zeros(movsz(1),movsz(2),floor(movsz(3)/sublen));
   
      
        for ll=1:floor(movsz(3)/sublen)
                    startfrm=1+sublen*(ll-1);
                    if ll~=floor(movsz(3)/sublen)
                        endfrm=sublen*ll;
                    else
                        endfrm=movsz(3);
                    end
                    %doing zstack
                    avgmov(:,:,ll)=mean(mov(:,:,startfrm:endfrm),3);
        end
            avgmov=padarray(avgmov,[pdsz,pdsz],'symmetric');%pad it

for mm=1:numROIs 
    ROIcents=fliplr(ROIs(mm,:));%because ginput is backwards
    pxb_r=round(ROIcents(1))+[-(bxsz-1)/2,(bxsz-1)/2];
    pxb_c=round(ROIcents(2))+[-(bxsz-1)/2,(bxsz-1)/2];

    for ll=1:floor(movsz(3)/sublen)
           
                data=avgmov(pxb_r(1):pxb_r(2),pxb_c(1):pxb_c(2),ll);
                
                [fitPars,conf95,~,~]=gaussFit(data,'searchBool',0,'nPixels',bxsz,'checkVals',0);
               
                % Debugging prints
                %disp(['Sublength ', num2str(ll)]);
                %disp(['conf95: ', num2str(conf95)]);
                %disp(['fitPars: ', num2str(fitPars)]);

               if any(conf95([1,2])>0.7)||any(isempty(fitPars))
                    %leave it as NaN and address it later
                   warning(['Bad Fit for ROI ',num2str(mm),' in sublength ',num2str(ll),'choose bigger box size or sublen'])
     
                else
                    fit_crds(1,mm,ll,:)=fitPars([1,2])+[pxb_r(1),pxb_c(1)]-1;
                    disp(['Updated fit_crds for ROI ', num2str(mm), ', sublength ', num2str(ll), ': ', num2str(fit_crds(1, mm, ll, :))]);
                end
    end
            
end      
%append the beads coords to the fits .mat file
  avgmov=avgmov((pdsz+1):(size(avgmov,1)-pdsz),(pdsz+1):(size(avgmov,2)-pdsz),:);%unpad the avgmov matrix
  beads_coords=fit_crds(:,:,:,:)-pdsz;%shift back from the padding
  beadscoordsublen=sublen;

%% Calculate means of shifts for multiple beads and relative coordinates for molecule fits based on shifted bead coords

%initialize variables for calculating the means of the shifted coordinates
%- this is only relevant in the case where you have multiple beads but for
%the sake of universal compatibility, we will run it
xshift=zeros(floor(movsz(3)/sublen),numROIs);
yshift=zeros(floor(movsz(3)/sublen),numROIs);
meanXshift=zeros(floor(movsz(3)/sublen),1);
meanYshift=zeros(floor(movsz(3)/sublen),1);

for ll=1:floor(movsz(3)/sublen)
    for mm=1:numROIs
    xshift(ll,mm)=beads_coords(1,mm,ll,1)-beads_coords(1,mm,1,1);
    yshift(ll,mm)=beads_coords(1,mm,ll,2)-beads_coords(1,mm,1,2);
    end
    meanXshift(ll)=mean(xshift(ll,:));
    meanYshift(ll)=mean(yshift(ll,:));
end
%load([sname,'_AccBGSUB_fits','.mat'],'fits');
load([sname,'_fits','.mat'],'fits');
%calculate number of frames per bead position
    fpbp = beadscoordsublen;
    %Loop through the different bead positions
    currfr = 1;
    original_fits=fits;
    for ii = 1:size(beads_coords,3)
        prevfr=(ii*fpbp)-fpbp+1;
        if ii == size(beads_coords,3)
            endframe=max([fits.frame]);
            currfr = endframe + 1;
        else
            currfr = prevfr + fpbp;
        end

        for k = 1:length(fits.frame)  
            if fits.frame(k) < currfr && fits.frame(k) >= prevfr
            fits.row(k) = fits.row(k) - (meanXshift(ii));
            fits.col(k) = fits.col(k) - (meanYshift(ii));
            else 
            fits.row(k) = fits.row(k);
            fits.col(k) = fits.col(k);  
            end
        end
    end
  % reset good fit logical to 0 if fit comes from an ROI with fewer than
  % MinNum *track localizations* localizations

load([sname,'_fits','.mat'],'tracks');
    %load([sname,'_AccBGSUB_fits','.mat'],'tracks');
roinums=tracks(:,5); %this line causes the script to search for min ROIs by track number (not by fit number)
uniqueROIs=unique(roinums);
minVal=min(uniqueROIs);
maxVal=max(uniqueROIs);
binEdges=(double(minVal)-0.5):(double(maxVal)+0.5);
ROIcounts=histcounts(roinums,binEdges);
rois=fits.roinum; %this line and the next takes the minROIs set above and finds the index of FITS that meet this criteria
sufficientData=ismember(rois,uniqueROIs(ROIcounts>=MinNum));

for i=1:length(fits.goodfit)
    fits.goodfit(i)=fits.goodfit(i)*sufficientData(i);
end

    
    currfr = 1;
    original_tracks=tracks;

    matchingRows=ismember(tracks(:,5),uniqueROIs(ROIcounts>=MinNum));
    tracks=tracks(matchingRows,:);

    for ii = 1:size(beads_coords,3)
        prevfr=(ii*fpbp)-fpbp+1;
        if ii == size(beads_coords,3)
            endframe=max([fits.frame]);
            currfr = endframe + 1;
        else
            currfr = prevfr + fpbp;
        end

        for k = 1:length(tracks)  
            if tracks(k,1) < currfr && tracks(k,1) >= prevfr
            tracks(k,2) = tracks(k,2) - (meanXshift(ii));
            tracks(k,3) = tracks(k,3) - (meanYshift(ii));
            else 
            tracks(k,2) = tracks(k,2);
            tracks(k,3) = tracks(k,3);  
            end
        end
    end



     %save([sname,'_drift_corr_AccBGSUB_fits','.mat'],'beads_coords','beadscoordsublen','avgmov','fits','original_fits','tracks','original_tracks')
     save([sname,'_drift_corr_fits','.mat'],'-v7.3','beads_coords','beadscoordsublen','avgmov','fits','original_fits','tracks','original_tracks')
     
end