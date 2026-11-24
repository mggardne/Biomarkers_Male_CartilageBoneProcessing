%#######################################################################
%
%               * FEMUR Cartilage Bone 7 Program *
%
%          M-File which reads cartilage and subchondral bone csv files,
%          plots out the segmented data, references the data into the
%          femoral coordinate system and saves variables into MAT files for
%          each knee.
%
%     NOTES:  1.  ALL CSV data files (With consistent file name convention
%                 must be in the current directory for each segmented knee;
%                 including, axial coordinate system(*AX_FEMUR), saggital 
%                 subchondral bone of femoral condyles and trochlea 
%                 (*SAG_femcondyles), sagittal cartilage of femoral
%                 condyles and trochlea (*AX_femcondylescart), and axial
%                 trochlea cartilage (
%
%
%             3.  MAT files  must be in the current directory.
%
%             4.  The M-files  must be in the current path or directory.
%
%     Daniel R. Sturnick - 26June2014
%
%#######################################################################
%
% Get list of filenames starting with the 'femcondyles' segmentation
%
cl;

d = dir('*SAG_FEM_EA.csv');
nams = char(d.name);
nams = reorder(nams);
%
% Constants
%
hpi = pi/2;             % Half pi
dpi = 2*pi;             % Double pi
%
% Let user select files to process
%
ok = 0;
while (ok==0)
     [filesel,ok] = listdlg('ListString',nams,'Name', ...
     'ROI Axial CSV Data Files','PromptString', ...
     'Select a file for plotting','SelectionMode','multiple');
end
fnams = nams(filesel,:);
fnams = reorder(fnams);
ifiles = 1;
nfiles = size(fnams,1);
%
% Set up figures
%
hf1 = figure;
hf2 = figure;
hf3 = figure;
hf4 = figure;
hf5 = figure;
hf6 = figure;
%
% Set up spreadsheet
%
fid = fopen('dig_rdif.csv','w');
fprintf(fid,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n','knum','dsaavg','dsastd','dsamin','dsamax' ...
    ,'dsaaavg','dscavg','dscstd','dscmin','dscmax','dscaavg','dscaavg','dscastd','dscamin','dscamax','dscaaavg');
%
% Loop through knees
%
for k = ifiles:nfiles
%    
    fnam = deblank(fnams(k,:));
%
% Get list of file names
%
    fnam1 = fnam; % sagittal bone
    fnam2 = strrep(fnam,'SAG_FEM','SAGAR_FEMCART'); % sagittal cartilage
    if ~exist(fnam2,'file')
        fnam2 = strrep(fnam2,'EA','AM');
    end
    fnam3 = strrep(fnam,'SAG_FEM_EA','AX_FEMCART_EA'); % axial cartilage
    fnam4 = strrep(fnam,'SAG_FEM_EA','AX_FEMUR_EA'); % axial coordinate system
%     fnam4 = ['bm male femur cs/' fnam4];
    fnam5 = strrep(fnam,'SAG_FEM_EA','CORAR_FEMCART_EA'); % coronal cartilage
    idu = strfind(fnam3,'_');
%     while idu(1)<4
%         fnam3 = ['0' fnam3];
%         fnam5 = ['0' fnam5];
%         idu = strfind(fnam3,'_');
%     end
 if exist(fnam3,'file')
%
% Get Knee Information
%
    idu = strfind(fnam(1,:),'_');
    num_knee = eval(fnam(1,1:idu(1)-1));
    initials = fnam((idu(4)+1):(idu(4)+2));
    if strcmp(fnam(idu(1)+1),'R');
     leg = true;        % Right leg
    else
     leg = false;       % Left leg
    end
    knum = fnam(1,1:idu(1)+1);
    while size(knum,2)<5
       knum = ['0' knum];
    end
%
% Read ROI data
%
    roibs = rd_roi3(fnam1);
    roics = rd_roi3(fnam2);
    roica = rd_roi3(fnam3);
    roiba = rd_roi3(fnam4);
    roicc = rd_roi3(fnam5);
    roinams1 =lower(char(roibs.name));
    roinams2 =lower(char(roics.name));
    roinams3 =lower(char(roica.name));
    roinams4 =lower(char(roiba.name));
    roinams5 =lower(char(roicc.name));
%
% Create Data Cell Arrays
%
    idc = zeros(14,1);
    idc(1,1) = strmatchn('latcondyle',roinams1,'exact');
    idc(2,1) = strmatchn('medcondyle',roinams1,'exact');
    idc(3,1) = strmatchn('trochlear',roinams1,'exact');
    if idc(3,1)==0
         idc(3,1) = strmatchn('trochlea',roinams1,'exact');
    end
    idc(4,1) = strmatchn('latcondylecart',roinams2,'exact');
    idc(5,1) = strmatchn('medcondylecart',roinams2,'exact');
    idc(6,1) = strmatchn('trochlearcart',roinams2,'exact');
    if idc(6,1)==0
         idc(6,1) = strmatchn('trochleacart',roinams2,'exact');
    end
    idc(7,1) = strmatchn('latcondylecart',roinams3,'exact');
    idc(8,1) = strmatchn('medcondylecart',roinams3,'exact');
    idc(9,1) = strmatchn('trochlearcart',roinams3,'exact');
    if idc(9,1)==0
         idc(9,1) = strmatchn('trochleacart',roinams3,'exact');
    end
    idc(10,1) = strmatchn('centerpt',roinams4,'exact');
    idc(11,1) = strmatchn('femshaft1',roinams4,'exact');
    idc(12,1) = strmatchn('latcondylecart',roinams5,'exact');
    idc(13,1) = strmatchn('medcondylecart',roinams5,'exact');
    idc(14,1) = strmatchn('trochlearcart',roinams5,'exact');
%    
    datlb = roibs(idc(1,1)).data';
    datmb = roibs(idc(2,1)).data';
    dattb = roibs(idc(3,1)).data';
    datlcs = roics(idc(4,1)).data';
    datmcs = roics(idc(5,1)).data';
    dattcs = roics(idc(6,1)).data';
    datlca = roica(idc(7,1)).data';
    datmca = roica(idc(8,1)).data';
    dattca = roica(idc(9,1)).data';
    datcp = roiba(idc(10,1)).data';
    datfs = roiba(idc(11,1)).data';
    datlcc = roicc(idc(12,1)).data';
    datmcc = roicc(idc(13,1)).data';
    dattcc = roicc(idc(14,1)).data';
    %
     %
 % Plot and Save Data
 %
    figure(hf1);
    hold on;
    axis equal;
    pt = plt_datsl(dattb,'r.-',1.5);
    pm = plt_datsl(datmb,'b.-',1.5);
    pl = plt_datsl(datlb,'g.-',1.5);
    l1 = legend([pt,pm,pl],'Trochlea','Medial Condyle','Lateral Condyle');
    title({[knum ' Femur'];'Bone Data'}, ...
         'FontSize',16,'FontWeight','bold','Interpreter','none');
    view(3);
%    
    figure(hf2);
    hold on;
    axis equal;
    pts = plt_datsl(dattcs,'r.-',1.5);
    pta = plt_datsl(dattca,'y.-',1.5);
    ptc = plt_datsl(dattcc,'g.-',1.5);
    pms = plt_datsl(datmcs,'r.-',1.5);
    pma = plt_datsl(datmca,'y.-',1.5);
    pmc = plt_datsl(datmcc,'g.-',1.5);
    pls = plt_datsl(datlcs,'r.-',1.5);
    pla = plt_datsl(datlca,'y.-',1.5);
    plc = plt_datsl(datlcc,'g.-',1.5);
    l2 = legend([pts,pta,ptc],'Sagittal Cartilage Data','Axial Cartilage Data','Coronal Cartilage Data');
    title({[knum ' Femur'];'Cartilage Data'}, ...
         'FontSize',16,'FontWeight','bold','Interpreter','none');
    view(3);
%    
    figure(hf3);
    hold on;
    axis equal;
    pb = plt_datsl([datlb;datmb;dattb],'k.-',1.5);
    pc = plt_datsl([datlcs;datmcs;dattcs;datlca;datmca;dattca;datlcc;datmcc;dattcc],'r.-',1.5);
    l3 = legend([pb,pc],'Bone Data','Cartilage Data');
    title({[knum ' Femur'];'Combined Data'}, ...
         'FontSize',16,'FontWeight','bold','Interpreter','none');
    view(3);
%
% Transform to Femur Coordinate System
%
   [xyzo,xyzax,xyzlnx,rcyl] = f_cs_14(datlb,datmb,datfs,datcp,false,25);
   [datlbt,datmbt,dattbt,datlcst,datmcst,dattcst,datlcat,datmcat,dattcat,datlcct,datmcct,dattcct] = ...
       coord_tf(xyzo,xyzax',datlb,datmb,dattb,datlcs,datmcs,dattcs, ...
       datlca,datmca,dattca,datlcc,datmcc,dattcc);
%
% Get Slice Information
%
   [nlc,nslc,islc] = sl_info(datlcst);
   [nmc,nsmc,ismc] = sl_info(datmcst);
   [ntc,nstc,istc] = sl_info(dattcst);
   [nlb,nslb,islb] = sl_info(datlbt);
   [nmb,nsmb,ismb] = sl_info(datmbt);
   [ntb,nstb,istb] = sl_info(dattbt);
%
% Transform to Cylindrical Coordinate System
%
   xyzlc = cell2mat(datlcst);
   xyzmc = cell2mat(datmcst);
   xyztc = cell2mat(dattcst);
   xyzlb = cell2mat(datlbt);
   xyzmb = cell2mat(datmbt);
   xyztb = cell2mat(dattbt);
%
   [tlc,rlc,zlc] = cart2pol(xyzlc(:,1),xyzlc(:,3),xyzlc(:,2));
   id = find(tlc>hpi);                 % Greater than pi/2
   tlc(id) = tlc(id)-dpi;              % Minus 2*pi
%
   [tmc,rmc,zmc] = cart2pol(xyzmc(:,1),xyzmc(:,3),xyzmc(:,2));
   id = find(tmc>hpi);                 % Greater than pi/2
   tmc(id) = tmc(id)-dpi;              % Minus 2*pi
%
   [ttc,rtc,ztc] = cart2pol(xyztc(:,1),xyztc(:,3),xyztc(:,2));
   id = find(ttc>hpi);                 % Greater than pi/2
   ttc(id) = ttc(id)-dpi;              % Minus 2*pi
%
   [tlb,rlb,zlb] = cart2pol(xyzlb(:,1),xyzlb(:,3),xyzlb(:,2));
   id = find(tlb>hpi);                 % Greater than pi/2
   tlb(id) = tlb(id)-dpi;              % Minus 2*pi
%
   [tmb,rmb,zmb] = cart2pol(xyzmb(:,1),xyzmb(:,3),xyzmb(:,2));
   id = find(tmb>hpi);                 % Greater than pi/2
   tmb(id) = tmb(id)-dpi;              % Minus 2*pi
%
   [ttb,rtb,ztb] = cart2pol(xyztb(:,1),xyztb(:,3),xyztb(:,2));
   id = find(ttb>hpi);                 % Greater than pi/2
   ttb(id) = ttb(id)-dpi;              % Minus 2*pi
%
% Check Sagittal Cartilage Slices
%
   ilat = true;
   for l = 1:nlc
      idx = islc(l)+1:islc(l+1);
      t = tlc(idx);
      r = rlc(idx);
      z = zlc(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        ilat = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        tlc(idx) = ts;
        rlc(idx) = r(idxs);
        zlc(idx) = z(idxs);
      end      
   end
%
   imed = true;
   for l = 1:nmc
      idx = ismc(l)+1:ismc(l+1);
      t = tmc(idx);
      r = rmc(idx);
      z = zmc(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        imed = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        tmc(idx) = ts;
        rmc(idx) = r(idxs);
        zmc(idx) = z(idxs);
      end      
   end
%
   itro = true;
   for l = 1:ntc
      idx = istc(l)+1:istc(l+1);
      t = ttc(idx);
      r = rtc(idx);
      z = ztc(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        itro = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        ttc(idx) = ts;
        rtc(idx) = r(idxs);
        ztc(idx) = z(idxs);
      end      
   end
%
% Check Sagittal Bone Slices
%
   ilatb = true;
   for l = 1:nlb
      idx = islb(l)+1:islb(l+1);
      t = tlb(idx);
      r = rlb(idx);
      z = zlb(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        ilatb = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        tlb(idx) = ts;
        rlb(idx) = r(idxs);
        zlb(idx) = z(idxs);
      end      
   end
%
   imedb = true;
   for l = 1:nmb
      idx = ismb(l)+1:ismb(l+1);
      t = tmb(idx);
      r = rmb(idx);
      z = zmb(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        imedb = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        tmb(idx) = ts;
        rmb(idx) = r(idxs);
        zmb(idx) = z(idxs);
      end      
   end
%
   itrob = true;
   for l = 1:ntb
      idx = istb(l)+1:istb(l+1);
      t = ttb(idx);
      r = rtb(idx);
      z = ztb(idx);
      dt = diff(t);
      dts = sign(dt);
      ddts = diff(dts);
      if any(ddts~=0)
        itrob = false;
        ids = find(ddts~=0);
        signd = dts(ids);
        [ts,idxs] = sort(t);
        dts = diff(ts);
        if sign(dts(1))~=signd(1)
          ts = flipud(ts);
          idxs = flipud(idxs);
        end
        ttb(idx) = ts;
        rtb(idx) = r(idxs);
        ztb(idx) = z(idxs);
      end      
   end
%
% Save Files Requiring Changes
%
   if any(~[ilat; imed; itro; ilatb; imedb; itrob])
%
% Transform Back to Cartesian Coordinate System
%
     [xyzlc(:,1),xyzlc(:,3),xyzlc(:,2)] = pol2cart(tlc,rlc,zlc);
     [xyzmc(:,1),xyzmc(:,3),xyzmc(:,2)] = pol2cart(tmc,rmc,zmc);
     [xyztc(:,1),xyztc(:,3),xyztc(:,2)] = pol2cart(ttc,rtc,ztc);
     [xyzlb(:,1),xyzlb(:,3),xyzlb(:,2)] = pol2cart(tlb,rlb,zlb);
     [xyzmb(:,1),xyzmb(:,3),xyzmb(:,2)] = pol2cart(tmb,rmb,zmb);
     [xyztb(:,1),xyztb(:,3),xyztb(:,2)] = pol2cart(ttb,rtb,ztb);
%
% Reform Cell Arrays
%
     for l = 1:nlc
        datlcst{l} = xyzlc(islc(l)+1:islc(l+1),:);
     end
%
     for l = 1:nmc
        datmcst{l} = xyzmc(ismc(l)+1:ismc(l+1),:);
     end
%
     for l = 1:ntc
        dattcst{l} = xyztc(istc(l)+1:istc(l+1),:);
     end
%     
     for l = 1:nlb
        datlbt{l} = xyzlb(islb(l)+1:islb(l+1),:);
     end
%
     for l = 1:nmb
        datmbt{l} = xyzmb(ismb(l)+1:ismb(l+1),:);
     end
%
     for l = 1:ntb
        dattbt{l} = xyztb(istb(l)+1:istb(l+1),:);
     end
%
     [datlcs,datmcs,dattcs,datlb,datmb,dattb] = tf_coord(xyzax,xyzo,datlcst,datmcst, ...
                                     dattcst,datlbt,datmbt,dattbt);
   end
    

%
% Calculate Digitization Differences Btw Axial,Coronal and Sagittal Segmentation
%
% Coordinate Transformation from cartesian to cylindrical coordinates
%
    [dlb,dmb,dtcb,dlcs,dmcs,dtcs,dlca,dmca,dtca,dlcc,dmcc,dtcc,ro,r] = cyl_trnf(datlb,datmb,dattb,datlcs, ...
        datmcs,dattcs,datlca,datmca,dattca,datlcc,datmcc,dattcc);
%
% Combine all sagittal, axial, and coronal cartilage segmentations  
%
    dfs = comb_dat(dlcs,dmcs,dtcs);
    dfa = comb_dat(dlca,dmca,dtca);
    dfc = comb_dat(dlcc,dmcc,dtcc);
%
% Combine all sagittal, axial, and coronal cartilage segmentations  
%
    datlmtcs = comb_dat(datlcs,datmcs,dattcs);
    datlmtca = comb_dat(datlca,datmca,dattca);
    datlmtcc = comb_dat(datlcc,datmcc,dattcc);
    datlmtb = comb_dat(datlb,datmb,dattb);
    [datlmtcst,datlmtcat,datlmtcct,datlmtbt] = coord_tf(xyzo,xyzax',datlmtcs,datlmtca,datlmtcc,datlmtb);
    datfst = coord_tf(xyzo,xyzax',datlmtcs);

    trifsin = mk_tri4f(datfst);
    
%
% Calculate sagittal-axial plane digitization differences in the radial direction
%
    [davg,dstd,dmin,dmax,daavg,diff,r2,idn,idp,trifa,trzfa,trifs,trzfs] = dig_rdif2(dfs,dfa,false,hf4); %,trifsin);
%
% Transform difference data back into cartesian coordinates
%
%    ichk1 = tri_olap(trifs,trzfs(:,[1 3]),trifs,trzfs(:,[1 3]));
%    overlap = any(find(ichk1))
    %xyzfcs = cyl2cart(trzfs,ro,r);
    xyzfcs = cell2mat(datlmtcs);
    trzd1 = [trzfa(:,1) r2 trzfa(:,3)];
    trzd2 = [trzfa(:,1) trzfa(:,2) trzfa(:,3)];
    [xyzd1,xyzd2] = cyl2cart(trzd1,ro,r,trzd2);
%
% Plot sagittal-axial plane differences
%
    figure(hf4);
    hold on;
    view(3);
    hm = trimesh(trifsin,xyzfcs(:,1),xyzfcs(:,2),xyzfcs(:,3),'EdgeColor', ...
               [0.75 0.75 0.75],'FaceColor','none','LineWidth',0.5);
    pdn = plot3([xyzd1(idn,1) xyzd2(idn,1)]',[xyzd1(idn,2) xyzd2(idn,2)]',[xyzd1(idn,3) xyzd2(idn,3)]', ...
        'r-','Color',[0.5 0 0],'LineWidth',2);
    pdp = plot3([xyzd1(idp,1) xyzd2(idp,1)]',[xyzd1(idp,2) xyzd2(idp,2)]',[xyzd1(idp,3) xyzd2(idp,3)]', ...
        'b-','Color',[0 0 0.5],'LineWidth',2);
    title({[knum ' Femur'];'Cartilage Sagittal-Axial Differences'}, ...
         'FontSize',16,'FontWeight','bold','Interpreter','none');
    axlim = axis;
    txtc = axlim([1 4 6]);
    txtc = [0.98 1.05 1.05].*(txtc<0).*txtc+ ...
         [1.02 0.95 0.95].*(txtc>0).*txtc;
    text(txtc(1),txtc(2),txtc(3),{['Mean Difference = ', ...
       num2str(davg) ' mm']; ['SD = ' num2str(dstd) ' mm']; ...
       ['Minimum Difference = ' num2str(dmin) ' mm']; ...
       ['Maximum Difference = ' num2str(dmax) ' mm']}, ...
       'FontSize',12,'FontWeight','bold');
    xlabel('X (mm)','FontSize',12,'FontWeight','bold');
    ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
    zlabel('Z (mm)','FontSize',12,'FontWeight','bold');

%
% Calculate sagittal-coronal plane digitization differences in the radial direction
%
    [davg1,dstd1,dmin1,dmax1,daavg1,dif1,r21,idn1,idp1,trifc,trzfc]  = dig_rdif2(dfs,dfc,false,hf5);%,trifsin);
%
% Transform differences back into cartesion coordinates
%
    trzd1 = [trzfc(:,1) r21 trzfc(:,3)];
    trzd2 = [trzfc(:,1) trzfc(:,2) trzfc(:,3)];
    [xyzd3,xyzd4] = cyl2cart(trzd1,ro,r,trzd2);
%
% Plot sagittal-cornonal plane differences
%    
    figure(hf5);
    hold on;
    view(3);
    hm = trimesh(trifsin,xyzfcs(:,1),xyzfcs(:,2),xyzfcs(:,3),'EdgeColor', ...
               [0.75 0.75 0.75],'FaceColor','none','LineWidth',0.5);
    pdq = plot3([xyzd3(idn1,1) xyzd4(idn1,1)]',[xyzd3(idn1,2) xyzd4(idn1,2)]',[xyzd3(idn1,3) xyzd4(idn1,3)]', ...
        'r-','Color',[0.5 0 0],'LineWidth',2);
    pdr = plot3([xyzd3(idp1,1) xyzd4(idp1,1)]',[xyzd3(idp1,2) xyzd4(idp1,2)]',[xyzd3(idp1,3) xyzd4(idp1,3)]', ...
        'b-','Color',[0 0 0.5],'LineWidth',2);
    title({[knum ' Femur'];'Cartilage Sagittal-Coronal Differences'}, ...
         'FontSize',16,'FontWeight','bold','Interpreter','none');
    axlim = axis;
    txtc = axlim([1 4 6]);
    txtc = [0.98 1.05 1.05].*(txtc<0).*txtc+ ...
         [1.02 0.95 0.95].*(txtc>0).*txtc;
    text(txtc(1),txtc(2),txtc(3),{['Mean Difference = ', ...
       num2str(davg1) ' mm']; ['SD = ' num2str(dstd1) ' mm']; ...
       ['Minimum Difference = ' num2str(dmin1) ' mm']; ...
       ['Maximum Difference = ' num2str(dmax1) ' mm']}, ...
       'FontSize',12,'FontWeight','bold');
    xlabel('X (mm)','FontSize',12,'FontWeight','bold');
    ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
    zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
%
% Plot combined sagittal-coronal and sagittal-axial plane differences
%
    dif2 = [diff;dif1];
    idnnan = ~isnan(dif2);
    dif2 = dif2(idnnan);
    [dmin2,idmn2] = min(dif2);
    [dmax2,idmx2] = max(dif2);
    dstd2 = std(dif2);
    davg2 = mean(dif2);
    daavg2 = mean(abs(dif2));

    figure(hf6);
    hold on;
    view(3);
    hm = trimesh(trifsin,xyzfcs(:,1),xyzfcs(:,2),xyzfcs(:,3),'EdgeColor', ...
               [0.75 0.75 0.75],'FaceColor','none','LineWidth',0.5);
    pdn = plot3([xyzd1(idn,1) xyzd2(idn,1)]',[xyzd1(idn,2) xyzd2(idn,2)]',[xyzd1(idn,3) xyzd2(idn,3)]', ...
        'r-','Color',[0.5 0 0],'LineWidth',2);
    pdp = plot3([xyzd1(idp,1) xyzd2(idp,1)]',[xyzd1(idp,2) xyzd2(idp,2)]',[xyzd1(idp,3) xyzd2(idp,3)]', ...
        'b-','Color',[0 0 0.5],'LineWidth',2);
    pdq = plot3([xyzd3(idn1,1) xyzd4(idn1,1)]',[xyzd3(idn1,2) xyzd4(idn1,2)]',[xyzd3(idn1,3) xyzd4(idn1,3)]', ...
        'r-','Color',[0.5 0 0],'LineWidth',2);
    pdr = plot3([xyzd3(idp1,1) xyzd4(idp1,1)]',[xyzd3(idp1,2) xyzd4(idp1,2)]',[xyzd3(idp1,3) xyzd4(idp1,3)]', ...
        'b-','Color',[0 0 0.5],'LineWidth',2);
    title({[knum ' Femur'];'Combined Cartilage Sagittal-Axial and Sagittal-Coronal Differences'}, ...
         'FontSize',16,'FontWeight','bold','Interpreter','none');
    axlim = axis;
    txtc = axlim([1 4 6]);
    txtc = [0.98 1.05 1.05].*(txtc<0).*txtc+ ...
         [1.02 0.95 0.95].*(txtc>0).*txtc;
    text(txtc(1),txtc(2),txtc(3),{['Mean Difference = ', ...
       num2str(davg2) ' mm']; ['SD = ' num2str(dstd2) ' mm']; ...
       ['Minimum Difference = ' num2str(dmin2) ' mm']; ...
       ['Maximum Difference = ' num2str(dmax2) ' mm']}, ...
       'FontSize',12,'FontWeight','bold');
    xlabel('X (mm)','FontSize',12,'FontWeight','bold');
    ylabel('Y (mm)','FontSize',12,'FontWeight','bold');
    zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
%
% Output Digitization Differences to Spreadsheet 'dig_rdif.csv'
%
    fprintf(fid,'%s,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\n',knum,davg,dstd,dmin,dmax ...
            ,daavg,davg1,dstd1,dmin1,dmax1,daavg1,davg2,dstd2,dmin2,dmax2,daavg2);
    
    figure(hf1);
    if k==1
        print('-dpsc2','femur_bc7');
    else
        print('-dpsc2','femur_bc7','-append');
    end
    figure(hf2);
    print('-dpsc2','femur_bc7','-append');
    figure(hf3);
    print('-dpsc2','femur_bc7','-append');
    figure(hf4);
    print('-dpsc2','femur_bc7','-append');
    figure(hf5);
    print('-dpsc2','femur_bc7','-append');
    figure(hf6);
    print('-dpsc2','femur_bc7','-append');
%     pause;
    clf(hf1); 
    clf(hf2);
    clf(hf3);
    clf(hf4);
    clf(hf5);
    clf(hf6);
    clear('diff');
%     figure; hold on;  plt_datsl(datlca,'b.-',1); plt_datsl(datmca,'g.-',1);
    save([knum '_' initials 'bc7t'],'knum','leg','datlb','datmb','dattb', ...
        'datlcs','datmcs','dattcs','datlca','datmca','dattca', ...
        'datlcc','datmcc','dattcc','datcp','datfs','datlmtcs','datlmtca', ...
        'datlmtcc','datlmtb','datlmtcst','datlmtcat','datlmtcct','datlmtbt' ...
        ,'datlbt','datmbt','dattbt','datlcst','datmcst','dattcst','datlcat' ...
        ,'datmcat','dattcat','datlcct','datmcct','dattcct','xyzo','xyzax','rcyl');
%
 else
 fprintf(fid,'%s\n',fnam);
    end
end