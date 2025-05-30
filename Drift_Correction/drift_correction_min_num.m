%%%
% =========================================================================
%  drift_correction_min_num.m  
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

sublen=400; % how many frames to average together for tracking the fiducial. 
% Essentially this is the frequency with which you want to update your molecule positions. 
% For a 40 ms exposure time, a sublen of 200 corrects the drift every 8 seconds. 
% The whole length of the movie usually 3000-5000 frames update
fitboxSize=29; % the diameter of the box around the bead - how many pixels to use for fitting the bead
%must be a odd integer 
showBead_loc=1; %% whether you want to make showBEAD movie documenting the drift
pdsz=10; %pads the array so an error is not thrown if your bead is too close to the edge of the frame
MinNum=100; %Filter out any ROIS with fewer than MinNum tracks? Helpful when using a plasmid 
%with minimal expression. If you don't want to use, set to 0


%% select the original movies
display('Select the original.movie')
[datalist,dataloc,findex]=uigetfile([pwd filesep '*.mat*'],'multiselect','on');
if findex==0
    fprintf('no data selected\n')
    return
end

if ~iscell(datalist); datalist={datalist}; end
for ii=1:numel(datalist); datalist{ii}=[dataloc datalist{ii}]; end

[dlocs,dnames,dexts]=cellfun(@fileparts,datalist,'uniformoutput',false);

%% append the bead fit coords to fit.mat
for ii=1:length(datalist)
fit_crds=Find_beads_auto_LAM(datalist{ii},sublen,fitboxSize,[dlocs{ii},'\',dnames{ii}],pdsz,MinNum);


%% show bead moving

if showBead_loc==1
        v = VideoWriter([dlocs{ii},'\',dnames{ii},'view_bead','_zstack','.avi'],'Uncompressed AVI');
        open(v);   
        figure
        set(gcf,'Position',[486 325  468 468])
        %load([dlocs{ii},'\',dnames{ii},'_drift_corr_AccBGSUB_fits','.mat'],'avgmov','beads_coords');
        load([dlocs{ii},'\',dnames{ii},'_drift_corr_fits','.mat'],'avgmov','beads_coords');
        movsz=size(avgmov);%the size of the movie
        
        for ll=1:length(fit_crds)
            GNR_loc=[beads_coords(1,:,ll,1)' beads_coords(1,:,ll,2)'];
            numGNR=size(GNR_loc,1);
            %         figure;
            imshow(avgmov(:,:,ll),[])
            
            hold on
            for jj=1:numGNR
                pxb_x=GNR_loc(jj,2)+[-(fitboxSize-1)/2,(fitboxSize-1)/2];
                pxb_y=GNR_loc(jj,1)+[-(fitboxSize-1)/2,(fitboxSize-1)/2];
                
                plot(pxb_x(1):pxb_x(2),repmat(pxb_y(1),[1,round(pxb_x(2)-pxb_x(1)+1)]),'r','LineWidth',2)%upper edge
                plot(pxb_x(1):pxb_x(2),repmat(pxb_y(2),[1,round(pxb_x(2)-pxb_x(1)+1)]),'r','LineWidth',2)%lower edge
                plot(repmat(pxb_x(1),[1,round(pxb_y(2)-pxb_y(1)+1)]),pxb_y(1):pxb_y(2),'r','LineWidth',2)%right edge
                plot(repmat(pxb_x(2),[1,round(pxb_y(2)-pxb_y(1)+1)]),pxb_y(1):pxb_y(2),'r','LineWidth',2)%left edge
                text(GNR_loc(jj,2)-(fitboxSize+1-10),GNR_loc(jj,1)...
                    +(fitboxSize-10),num2str(jj),'color','red','fontsize',13,'fontweight','bold');
            end
            
            
            
            hold off
            ax = gca;
            ax.Units = 'pixels';
            pos = ax.Position;
            ti = ax.TightInset;
            rect = [-ti(1), -ti(2), pos(3)+ti(1)+ti(3), pos(4)+ti(2)+ti(4)];
            F = getframe(ax,rect);
            
            imshow(F.cdata)
            writeVideo(v,F);
            
        end
        close all
    
end
end
clear
