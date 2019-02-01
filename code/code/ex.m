pos = {'A1','B1'};
for i = 1:4
  xdis  = [1:10]';
  ydis  = rand(10,1);
  xlswrite('StreamLines.xls',xdis,1,pos{i})
  xlswrite('StreamLines.xls',ydis,1,pos{i})
end