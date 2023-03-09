%This Matlab script will load data from 100 Alaskan rivers. The data
%contain the climatological hydrographs. In other words, for each 
%day of the year, the data files contain the long term average for the flow
%for that day. All data were obtained from here:
%https://nwis.waterdata.usgs.gov/ak/nwis/sw

%Additionally, I used flow classifications. See the paper by Curran et al.
%here: https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2020WR028425.
%And, there is a useful spreadsheet with classifications here:
%https://alaska.usgs.gov/products/data.php?dataid=355. While Curran's work
%has 'sub-classes', I stuck with just three. And, for the purposes of
%simplifying the resultant figure, I chose 'Ice' rather than 'high
%elevation melt.' Call it artistic license....Note: Curran's spreadsheet
%has hundreds of rivers. I only took the top 100 (based on length of period
%of record). So, the data files in this repo (there are ten of them)
%contain ten rivers each.

%David Hill
%dfhkvs@gmail.com
%@dfosterhill (twitter / insta)

%First, load the csv file with classes
clear all
close all

data=readtable('ak_river_classes.csv');
stations=data.site_no;
classes=data.SFR_class;

%choose 1 to smooth; 0 to not smooth. If you enable this option, a simple
%5-point moving average filter will be applied...It's personal choice
%whether you like this or not. I prefer the non-smoothed data.
smoothflag=0;

%loop through flow files and analyze
for j=1:10 
    %read in file...should be 10 blocks of 366 rows
    datatmp=readtable(['akflow',num2str(j),'.txt']);
    sta=datatmp.site_no;
    flow=datatmp.p50_va;

    %loop over the 10 stations in each file
    for k=1:10

        %grab the station ID of the kth station.
        stationid=sta((k-1)*366+1);
        
        %begin to build up matrix of results. This matrix will have 100
        %columns and 368 rows. First row is ID, second row is class,
        %remaining rows are mean flows for each day of the year.
        results(1,(j-1)*10+k)=stationid;
        
        %use this station ID to lookup/find the flow classification (1,2,3)
        I=find(stations==stationid);
        flowclass=classes(I);
        results(2,(j-1)*10+k)=flowclass;

        %pull the flows
        if smoothflag
            stationflows=smooth(flow((k-1)*366+1:k*366));
        else
            stationflows=flow((k-1)*366+1:k*366);
        end
        %here I normalize each hydrograph to a max value of 1. An
        %alternative approach would be to normalize by the 'average' flow
        %instead of the max....
        results(3:368,(j-1)*10+k)=[stationflows/max(stationflows)]'; 
    end

end

%Ok, so let's plot things up. Basically, I just displace the hydrographs
%vertically...There is a ton of 'sizing' stuff below aimed at replicating
%the size / aspect ratio of the original album cover.

figure(1)
%this scale factor just stretches the hydrographs vertically. It is
%arbitrary. Please experiment with it to find something you visually like.
%I found that a value of 10 looked pretty nice.
scalingfactor=10;

set(gcf,'PaperPosition',[0 0 6 9.8])
for j=1:size(results,2)
    hydro=results(3:end,j);
    flowtype=results(2,j);
    xvar=1:366;
    ytmp=(10-j+hydro*scalingfactor);
    p=fill([xvar 366 1 1],[ytmp' 10-j 10-j (10-j)+hydro(1)*scalingfactor],'black');
    p.EdgeColor='black';
    hold on
    if flowtype==1
        plot(xvar,ytmp,'blue','LineWidth',.75)
    elseif flowtype==2
        plot(xvar,ytmp,'cyan','LineWidth',.75)
    else
        plot(xvar,ytmp,'magenta','LineWidth',.75)
    end
end
set(gca,'Color','k')
set(gca,'OuterPosition',[0 0 1 1]);
set(gca,'Position',[.0306 .1513 .939 .738])
axis([0 366 -90 20])
box off
axis off

%Let's add text
h=annotation('textbox',[0.0306 0.88 0.95 0.1],'String','FLOW DIVISION');
h.FontSize=54;
h.FontName='helvetica';
set(h,'Color','white');

h2=annotation('textbox',[0.0306 0.04 0.95 0.1],'String','DOMINANT MEASURES');
h2.FontSize=36;
h2.FontName='helvetica';
set(h2,'Color','white');

%And color boxes for the various hydrograph drivers...whole bunch of fiddly
%matlab position crap below...

boxlabeloffset=0.08;
boxoffset=0.325;
boxsize=0.06;
scalefactor=0.6125;
firstbox=0.04;

h3=annotation('rectangle');
h3.FaceColor='blue';
h3.Color='white';
h3.Position=[firstbox .03 boxsize boxsize*scalefactor];

h4=annotation('rectangle');
h4.FaceColor='magenta';
h4.Color='white';
h4.Position=[firstbox+boxoffset+0.03 .03 boxsize boxsize*scalefactor];

h5=annotation('rectangle');
h5.FaceColor='cyan';
h5.Color='white';
h5.Position=[firstbox+2*boxoffset .03 boxsize boxsize*scalefactor];

%more text...
h=annotation('textbox',[firstbox+boxlabeloffset 0.024 0.2 0.05],'String','RAIN');
h.FontSize=24;
h.FontName='helvetica';
set(h,'Color','white');

h=annotation('textbox',[firstbox+boxoffset+boxlabeloffset+0.03 0.024 0.2 0.05],'String','ICE');
h.FontSize=24;
h.FontName='helvetica';
set(h,'Color','white');

h=annotation('textbox',[firstbox+2*boxoffset+boxlabeloffset 0.024 0.2 0.05],'String','SNOW');
h.FontSize=24;
h.FontName='helvetica';
set(h,'Color','white');

set(gcf, 'InvertHardCopy', 'off'); 
set(gcf,'Color',[0 0 0]); % RGB values [0 0 0] indicates black color

%print the files
print -dpng -r600 flowdivision.png
print -djpeg -r600 flowdivison.jpg
