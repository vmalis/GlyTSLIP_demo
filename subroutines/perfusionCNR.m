%==========================================================================
% Subroutine to get perfusion-CNR
%==========================================================================
%
% Here you read manual ong ROIs
% 
% INput:        tag on and tag off and cnr volume
%
% OUTput:       average cnr
%
%--------------------------------------------------------------------------
% written by Vadim Malis
% 03/21 at UCSD Health / Canon
%==============================


function cnr=perfusionCNR(cnr_volume,slice_number,maskI,OFF_original,ON_original,filterType)

if strcmp(filterType,'Median')      % medianfilter, tends to increase values by smothing low value voxels
    disp('Median')
    cnr_image = medfilt2(squeeze(cnr_volume(:,:,slice_number)));
    cnr = mean(cnr_image.*maskI,'all','omitnan');
elseif strcmp(filterType,'SD')      % just average on average most robust performance
    cnr = (abs(mean(OFF_original.*maskI,'all','omitnan') - mean(ON_original.*maskI,'all','omitnan')))/abs(mean(OFF_original.*maskI,'all','omitnan'));
else                                % sd filter
    disp('SDpp')
    cnrOFF = mean(OFF_original.*maskI,'all','omitnan');
    cnrON = mean(ON_original.*maskI,'all','omitnan');
    cnrOFFsd = std(OFF_original.*maskI,0,'all','omitnan');
    cnrONsd = std(ON_original.*maskI,0,'all','omitnan');
    
    uBOFF = cnrOFF+cnrOFFsd;
    lBOFF = cnrOFF-cnrOFFsd;
    uBON = cnrON+cnrONsd;
    lBON = cnrON-cnrONsd;
    
    OFF_original=OFF_original.*maskI;
    OFF_original(OFF_original<lBOFF)=nan;
    OFF_original(OFF_original>uBOFF)=nan;
    
    ON_original=ON_original.*maskI;
    ON_original(ON_original<lBON)=nan;
    ON_original(ON_original>uBON)=nan;
    cnr = abs(mean(OFF_original,'all','omitnan')-mean(ON_original,'all','omitnan'))./abs(mean(OFF_original,'all','omitnan'));
end