%==========================================================================
%% Glymphatic flow analysis: demo code
%  
%==========================================================================
%
%   05/2021 - VM  (vmalis@ucsd.edu)
%
%==========================================================================
%
%   test set provided @ Zenodo
%   10.5281/zenodo.6792179
%                         
%--------------------------------------------------------------------------
clear all
clc

subjectID = '01';
studyName = 'Study #1';
roiName   = 'some ROI';


% structure with results: appended at each subject
Results = [];   
list = dir2();
q=1;    

%%
    for k=1:size(list,1)
    
        cd(list(k,1).name)
        list_dcm=dir('I*.dcm');
       
        
        %if error change to ms -> MS
        ms_index = min(strfind(list(k,1).name,'MS'));
        uScore_index = strfind(list(k,1).name,' ');
        uScore_index(uScore_index>ms_index)=[];
        
        if uScore_index(end) == ms_index-1
            TI = str2double(list(k,1).name(uScore_index(end-1)+1:uScore_index(end)-1));
        else
            TI = str2double(list(k,1).name(uScore_index(end)+1:ms_index-1));
        end
        
        % read images
        [I,S]=dicom2struct_canon(cd,'data');
        thickness=round(S(1).header.SliceThickness/S(1).header.PixelSpacing(1));
        thickness=thickness/size(I,1)*800;
        
        
        % split to tag on tag off
        ON  = double(I(:,:,1:end/2));
        OFF = double(I(:,:,end/2+1:end));
        
        % calculate ratio
        ON_original = ON;
        OFF_original = OFF;

        if k==1
            slice=selectSlice(ON);
            if isempty(slice)
                slice=ceil(size(ON,3)/2);
            end

            imshow(mat2gray(ON(:,:,slice)),'InitialMagnification',400)
            roi      =   drawfreehand(gca,'Color','y','Label','Signal');
            maskI     =   double(roiWait(roi));
            close
        end

        


        % ROI
        if max(size(size(OFF)))>2
            ON=medfilt3(ON);
            OFF=medfilt3(OFF);
        else
            ON=medfilt2(ON);
            OFF=medfilt2(OFF);
        end
            
        cnr_volume = abs(OFF-ON)./abs(OFF);
        cnr_volume(cnr_volume==Inf)=NaN;
        
        cnr = perfusionCNR(cnr_volume,slice,maskI,OFF_original,ON_original,'SD');
        
        
            Result(q).TI  = TI;
            Result(q).cnr = cnr;

        
            min_res=min(size(OFF));
            max_res=max(size(OFF));
            

            cd ..
            q=q+1;
            

    end
    

        Result = sortStruct2(Result,'TI');  %sort by TI

        [FitPara, PH4a, TTP4a, MTT4a, MBV4a, MBF4a,x,Stest4] = ...
                perfusionFitDemo([Result.TI],[Result.cnr], ...
                [subjectID,'-',studyName,'',roiName],roiName);
        
            
        ResultFit.ID   = subjectID;
	    ResultFit.studyName = studyName;
        ResultFit.roi = roiName;
	    ResultFit.FitPara=FitPara;
	    ResultFit.PH4a = PH4a;
	    ResultFit.TTP4a = TTP4a;
	    ResultFit.MTT4a = MTT4a;
	    ResultFit.MBV4a = MBV4a;
	    ResultFit.MBF4a = MBF4a;
	    ResultFit.TI=[Result.TI];
	    ResultFit.cnr=[Result.cnr];
	    ResultFit.x = x;
	    ResultFit.Stest4 = Stest4;


%% export table
timings = unique([ResultFit.TI]);
CNR = NaN([size(ResultFit,2),size(timings,2)]);

for i=1:size(ResultFit,2)
    
    for ti=1:size(timings,2)
        
        tiUSED = [ResultFit(i).TI];
        CNRmeasured = [ResultFit(i).cnr];
        
        for k = 1:size(tiUSED,2)
            if tiUSED(k)==timings(ti)
                CNR(i,ti)=CNRmeasured(k);
            else
                
            end
            
        end
        
    end
    
 
end


for i=1:size(Result,2)

    for ti=1:size(timings,2)
        Results(i).(sprintf('TI%d', timings(ti)))=CNR(i,ti);
    end
end

ResultFit=rmfield(ResultFit,{'FitPara','TI','cnr','x','Stest4'});
writetable([struct2table(ResultFit),struct2table(Results)], 'results.xlsx')

