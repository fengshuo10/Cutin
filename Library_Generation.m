function [ Library ] = Library_Generation( table, F_SurrModel, min_epislon )
% generate testing scenario library
% table: NDD
% F_SurroModel: performance

tmp = table .* F_SurrModel;
mu = sum(tmp(:));

Library = tmp ./ mu;

% epislon
[N1,N2] = size(table);
N = N1*N2;
thresh = 1/N;
I = Library > thresh;
W = sum(sum(tmp(I)));
epislon = 1- W / mu;
epislon = max(min_epislon,epislon);
Library(I) = (1-epislon) .* Library(I);
Library(~I) = epislon / sum(sum(~I));

end

