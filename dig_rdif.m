function [davg,dstd,dmin,dmax,daavg,dif,tri1,trz1,tri2,trz2,rdn,rdp,idn,idp,idmn,idmx,r2] = dig_rdif(dat1,dat2,iplt,hf);
%DIG_RDIF Gets the R (radius) difference between two MRI digitizations
%         of a surface using 2D interpolation.
%
%         [DAVG,DSTD,DMIN,DMAX] = DIG_RDIF(DAT1,DAT2) given cell arrays
%         of digitized MRI surface data, DAT1 and DAT2, interpolates the
%         R (radius) coordinates of DAT1 to the Theta (angle) and Z
%         coordinates of DAT2 and takes the differences in the R
%         coordinates.  The minimum difference, DMIN, (maximum negative
%         difference), maximum difference, DMAX, mean difference, DAVG,
%         and the standard deviation of the differences, DSTD are
%         returned.
%
%         [DAVG,DSTD,DMIN,DMAX,DAAVG] = DIG_RDIF(DAT1,DAT2) returns
%         the mean absolute difference, DAAVG.
%
%         [DAVG,DSTD,DMIN,DMAX,DAAVG,DIF] = DIG_RDIF(DAT1,DAT2) returns
%         a column vector of R differences, DIF, between the two
%         digitizations.  The differences will contain NaNs where DAT2
%         Theta-Z data is outside of the DAT1 Theta-Z data.
%
%         [DAVG,DSTD,DMIN,DMAX] = DIG_RDIF(DAT1,DAT2,IPLT) if IPLT is
%         true, the surfaces and differences are plotted in a new
%         figure.  The DAT2 surface is shown higher with red bars and
%         the DAT2 surface is shown lower with blue bars.  Maximum
%         differences are shown in darker red and blue.
%
%         NOTES:  1.  Works best on surfaces that are uniquely defined
%                 in the Theta-Z plane.
%
%                 2.  The M-files in_tri2d.m, mk_tri3.m, mk_tri4.m and
%                 plane_fit.m must be in the current path or directory.
%
%         02-Jul-2014 * Mack Gardner-Morse
%

%#######################################################################
%
% Check for Inputs
%
if (nargin<4)||isempty(hf)
  hf = figure;
end
if (nargin<3)||isempty(iplt)
  iplt = false;
end
%
if (nargin<2)
  error(' *** ERROR in DIG_RDIF:  Not enough input data!');
end
%
% Check Inputs
%
if ~iscell(dat1)||~iscell(dat2)
  error(' *** ERROR in DIG_RDIF:  Inputs must be cell arrays!');
end
%
dat1 = dat1(:);
dat2 = dat2(:);
%
% Get Surface Triangulations and Coordinates
%
tri1 = mk_tri4(dat1);   % First digitization
% tri1 = mk_tri3(dat1);   % First digitization
trz1 = cell2mat(dat1);  % First digitization
%
tri2 = mk_tri4(dat2);   % Second digitization
% tri2 = mk_tri3(dat2);   % Second digitization
trz2 = cell2mat(dat2);  % Second digitization
%
% Check Consistency of Digitization
%
tgrid = TriScatteredInterp(trz1(:,[1 3]),trz1(:,2),'linear');
r2 = tgrid(trz2(:,[1 3]));
it = in_tri2d(tri1,trz1(:,[1 3]),trz2(:,[1 3]));
r2(~it) = NaN;
%
dif = r2-trz2(:,2);
[dmin,idmn] = min(dif);
[dmax,idmx] = max(dif);
%
idnnan = ~isnan(dif);
dif2 = dif(idnnan);     % Remove NaNs
dstd = std(dif2);
davg = mean(dif2);
daavg = mean(abs(dif2));
%
if iplt
  figure(hf);
  orient landscape;
  hm = trimesh(tri1,trz1(:,1),trz1(:,2),trz1(:,3),'EdgeColor', ...
               [0.75 0.75 0.75],'FaceColor','none','LineWidth',0.5);
%  set(hm,'EdgeAlpha',0.5);
  axis equal;
  hold on;
%
  idn = find(dif<0);
  idp = find(dif>0);
%
  plot3([trz2(idn,1) trz2(idn,1)]',[r2(idn) ...
        trz2(idn,2)]',[trz2(idn,3) trz2(idn,3)]','r-', ...
        'Color',[0.5 0 0],'LineWidth',2);
%  
  plot3([trz2(idp,1) trz2(idp,1)]',[r2(idp) ...
        trz2(idp,2)]',[trz2(idp,3) trz2(idp,3)]','b-', ...
        'Color',[0 0 0.5],'LineWidth',2);
%  
  plot3([trz2(idmn,1); trz2(idmn,1)],[r2(idmn); ...
        trz2(idmn,2)],[trz2(idmn,3); trz2(idmn,3)],'r-', ...
        'LineWidth',3);
%
  plot3([trz2(idmx,1); trz2(idmx,1)],[r2(idmx); ...
        trz2(idmx,2)],[trz2(idmx,3); trz2(idmx,3)],'b-', ...
        'LineWidth',3);
%
  view(10,-24);
%
  axlim = axis;
  txtc = axlim([1 4 6]);
  txtc = [0.98 1.05 1.05].*(txtc<0).*txtc+ ...
         [1.02 0.95 0.95].*(txtc>0).*txtc;
  text(txtc(1),txtc(2),txtc(3),{['Mean Difference = ', ...
       num2str(davg) ' mm']; ['SD = ' num2str(dstd) ' mm']; ...
       ['Minimum Difference = ' num2str(dmin) ' mm']; ...
       ['Maximum Difference = ' num2str(dmax) ' mm']}, ...
       'FontSize',12,'FontWeight','bold');
  xlabel('Angle (degrees)','FontSize',12,'FontWeight','bold');
  ylabel('Radius (mm)','FontSize',12,'FontWeight','bold');
  zlabel('Z (mm)','FontSize',12,'FontWeight','bold');
  title('Digitization Differences','FontSize', ...
        16,'FontWeight','bold','Interpreter','none');
  rdn = [[trz2(idp,1) trz2(idp,1)]',[r2(idp) trz2(idp,2)]',[trz2(idp,3) trz2(idp,3)]'];
  rdp = [[trz2(idp,1) trz2(idp,1)]',[r2(idp) trz2(idp,2)]',[trz2(idp,3) trz2(idp,3)]'];
end
%
return