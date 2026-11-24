%#######################################################################
%
%                  * FEMUR SLice CURVature Program *
%
%          M-File which reads femur cartilage MAT files, transforms
%     the mid-condyle slice data to polar coordinates which are fit
%     with polynomials and calculates the curvature.
%
%          For looking at methods for determining limits for the 
%     circle fits on digitized slice data.
%
%     NOTES:  1.  For biomarkers study knees.
%
%             2.  See variable "ddir" for the data directory location.
%
%             3.  The M-files circ_fit.m, fitp.m, plane_fit.m and
%             rd_roi3.m must be in the current path or directory.
%
%     13-May-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Angles from 0 to 360 degrees
%
th = (0:pi/36:2*pi)';
%
% Compartment Labels
%
cmprt = ['Lateral'
         'Medial ' ];
%
% Plot Colors
%
clr = ['g';'r'];
%
% Get Directories and Data
%
cdir = ['C:\Users\Mack\BRUCE\Risk_Fac\Cartilage_Thick\', ...
        'Biomarkers Femurs\'];
%
% Get File Names
%
d = dir([cdir '*.csv']);
fnams = char(d.name);
fnams = reorder(fnams,'_');
%
[ids,nums] = get_subj(fnams);          % Subject knee numbers
%
subjn = unique(nums);
nsubj = size(subjn,1);
%
% Open Figure
%
hf1 = figure;
%
% Initialize Variables
%
h = zeros(4,1);
a = zeros(2*nsubj,4);
b = zeros(2*nsubj,6);
klim = 0.1;             % Curvature limit
%
% Loop through Knees
%
for k = 1:nsubj
%
   idf = find(nums==subjn(k));
   fnamk = fnams(idf,:);
   iu = strfind(fnamk,'_');
   snamk = fnamk(1:iu(2)-1);           % Subject number and leg as text
%
   dat = rd_roi3([cdir deblank(fnamk)]);
%
   for l = 1:2          % 1 - lateral, 2 - medial
%
      nslice = max(size(dat(l).data));
      ids = ceil(nslice/2);            % Index to "middle" slice
      xyz = dat(l).data{ids};
      npt = size(xyz,1);
      [mval,idmx] = max(xyz(:,2));
      if idmx<npt/2
        ibeg = true;
      else
        ibeg = false;
      end
%
% Plot Data
%
      figure(hf1);
      orient landscape;
      clf;
      h(1) = subplot(2,2,1);
      hold on;
%       view(-45,35);
      view(-75,35);
%
      plot3(xyz(:,1),xyz(:,2),xyz(:,3),[clr(l) '.-'],'LineWidth',0.5);
%
      axis equal;
      xlabel('X','FontSize',12,'FontWeight','bold');
      ylabel('Y','FontSize',12,'FontWeight','bold');
      zlabel('Z','FontSize',12,'FontWeight','bold');
%
% Get Mid-Condyle Slice Data into 2-D Slice Plane
%
      [xyzc2,nv2,c2,r2] = plane_fit(xyz(:,1),xyz(:,2),xyz(:,3));
      xyzt = (xyz-repmat(xyzc2,size(xyz,1),1))*r2;
%
% Circle Fit of Entire Slice
%
      [rc,xc,yc] = circ_fit(xyzt(:,1),xyzt(:,2));
%
      h(2) = subplot(2,2,2);
      orient landscape;
      plot(xyzt(:,1),xyzt(:,2),'b.-','LineWidth',0.5);
      hold on;
      x = rc*cos(th)+xc;
      y = rc*sin(th)+yc;
      plot(x,y,'k-','LineWidth',0.5);
      axis equal;
      xlabel('X','FontSize',12,'FontWeight','bold');
      ylabel('Y','FontSize',12,'FontWeight','bold');
%
% Convert to Polar Coordinates
%
      [th2,rc2] = cart2pol(xyzt(:,1),xyzt(:,2));
      na = size(th2,1);
%
% Make Angles (th2) Continuous
%
      dth2 = diff(th2);
      idb = find(abs(dth2)>pi);        % Find jump in angle
      if xor(idb<na/2,dth2(idb)<0)
        idn = find(th2<-pi/2);
        th2(idn) = th2(idn)+2*pi;      % Add 2*pi (360 degrees)
        rng = [-1 4];
      else
        idn = find(th2>pi/2);
        th2(idn) = th2(idn)-2*pi;      % Subtract 2*pi (360 degrees)
        rng = [-4 1];
      end
%
% Polynomial Fit of Polar Coordinates
% See Fit_errors.txt for measures of fit with different maximum
% polynomial orders (10-15).
%
      [b2,p2,df,R2,F,r2v,fv] = fitp(th2,rc2,11); % Max. order (11) picked so mxerr<1 (all, but 3) and sderr < 0.3 (all, but 1)
      rhat = polyval(b2,th2);
      err = rhat-rc2;
      mxerr = max(abs(err));
      sderr = std(err);
      b(2*k+l-2,:) = [nums(k) l p2 mxerr R2 sderr];
%
% Plot Polar Coordinates and Fit
%
      h(3) = subplot(2,2,3);
      plot(th2,rc2,'b.-','LineWidth',0.5,'MarkerSize',6);
      hold on;
      plot(th2,polyval(b2,th2),[clr(l) '-'],'LineWidth',0.5);
      xlabel('\Theta','FontSize',12,'FontWeight','bold');
      ylabel('R','FontSize',12,'FontWeight','bold');
      ttx = {[int2str(p2) ' Order Fit'];['Max Err = ' num2str(mxerr) ...
            ', R^2 = ' num2str(R2) ', SD Err = ' num2str(sderr)]};
      title(ttx,'FontSize',12,'FontWeight','bold');
%
% Get Derivatives and Curvature
%
      b2d = polyder(b2);
      b2d2 = polyder(b2d);
%
      k2 = polyval(b2d2,th2)./(1+polyval(b2d,th2).^2).^1.5;
%
% Find points within Limits
%
      [aval,loc] = max(abs(rng));
      aval = rng(loc);
      aval = aval-sign(aval);          % +3 or -3 (~pi)
      idl = find(abs(k2)<klim);
      nl = size(idl,1);
      idx = [0; find(abs(diff(idl))>1); nl];
      nx = size(idx,1);
      [mval,idmn] = min(abs(th2(idl)-aval));
      if idl(idmn)<npt/2&~ibeg|idl(idmn)>npt/2&ibeg        % Check +/-3 is in posterior
        [mval,idmn] = min(abs(th2(idl)));        % Use zero instead of +/-3 for posterior
      end
      [sid,ids] = sort([idx; idmn]);
      ie = find(ids==nx+1);
      ib = idx(ie-1)+1;
      ie = idx(ie);
      idk = idl(ib:ie);
%
% Plot Curvature
%
      h(4) = subplot(2,2,4);
      plot(rng,[0 0],'k:','LineWidth',0.5);
      hold on;
      plot(rng,[klim klim],'r:','LineWidth',0.5);
      plot(rng,-[klim klim],'r:','LineWidth',0.5);
      plot(th2,k2,'b-','LineWidth',0.5);
      plot(th2(idk),k2(idk),'ro','LineWidth',0.5);
      axis([rng -0.5 0.5]);
      xlabel('\Theta','FontSize',12,'FontWeight','bold');
      ylabel('K','FontSize',12,'FontWeight','bold');
%
% Plot Identified Points on Other Subplots
%
      axes(h(1));
      h1 = plot3(xyz(idk,1),xyz(idk,2),xyz(idk,3),'bo','LineWidth',0.5);
%
      axes(h(2));
      h2 = plot(xyzt(idk,1),xyzt(idk,2),'ro','LineWidth',0.5);
%
% Circle Fit and Plot using Identified Points
%
      [rc2,xc2,yc2] = circ_fit(xyzt(idk,1),xyzt(idk,2));
%
      x2 = rc2*cos(th)+xc2;
      y2 = rc2*sin(th)+yc2;
      plot(x2,y2,'r-','LineWidth',0.5);
      plot(xc2,yc2,'r+','LineWidth',0.5);
%
% Subject Name and Print Plots
%
      ht = suptitle([snamk ' - ' deblank(cmprt(l,:)) ' Cartilage']);
      set(ht,'FontSize',24,'FontWeight','bold','Interpreter','none');
      if k==1&&l==1
        print -dpsc2 femur_sl_curv.ps;
      else
        print -dpsc2 -append femur_sl_curv.ps;
      end
   end
end
%
return