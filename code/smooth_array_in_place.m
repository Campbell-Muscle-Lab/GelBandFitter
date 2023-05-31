function smoothed=smooth_array_in_place(data,half_size);

[rows,columns]=size(data);

% Pre-allocate array
smoothed=zeros(1,length(data));

% Now fill it
% First points

for i=1:half_size
    smoothed(i)=data(i);
end

% Mid-section

smoothed(half_size+1)=sum(data(1:2*half_size+1))/((2*half_size)+1);

for i=half_size+2:length(data)-half_size;
    smoothed(i)=smoothed(i-1)+(data(i+half_size)-data(i-half_size-1))/((2*half_size)+1);
end

% End points

for i=length(data)-half_size+1:length(data)
    smoothed(i)=data(i);
end

if (rows>columns)
    smoothed=smoothed';
end