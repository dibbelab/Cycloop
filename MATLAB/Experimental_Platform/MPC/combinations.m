%% combinations.m
%%% OCTOBER 14, 2020

function trials = combinations(N, nmaxpul)

ncomb=2^nmaxpul;
dec=0:ncomb-1;
comb=de2bi(dec);
trials=ones(ncomb,N);
passo=round(N/nmaxpul);
for i=1:ncomb
    for j=0:nmaxpul-1
    trials(i,1+round(j*passo))=comb(i,j+1);
    end
end

end

