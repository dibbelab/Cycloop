%% funCodeGen.m
%%% OCTOBER 12, 2020

function funCodeGen

% codegen InitCon_ -args {coder.typeof(0, 1, 0)} -o InitCon_ -report

codegen StopAndGoCTRL -args {coder.typeof(0, [1,2^15], [0,1]), coder.typeof(0, 1, 0)} -o StopAndGoCTRL -report

% codegen RefOscCTRL_ -args {coder.typeof(0, [500,2^16], [1,1]), coder.typeof(0, [500,1], [1,0])} -o RefOscCTRL_ -report

% codegen mpcCTRL -args {coder.typeof(0, 1, 0), coder.typeof(0, 1, 0), coder.typeof(0, [500,1], [1,0]), coder.typeof(0, [1,2^15], [0,1]), coder.typeof(0, [1,2^15], [0,1]), coder.typeof(0, 1, 0)} -o mpcCTRL -report

codegen CyclingODEs_ -args {coder.typeof(0, 1, 0), coder.typeof(0, [2^16,1], [1,0]), coder.typeof(0, 1, 0), coder.typeof(0, 1, 0)} -o CyclingODEs_ -report

codegen NonCyclingODEs_ -args {coder.typeof(0, 1, 0), coder.typeof(0, [2^16,1], [1,0]), coder.typeof(0, 1, 0), coder.typeof(0, 1, 0)} -o NonCyclingODEs_ -report

codegen div_Events_ -args {coder.typeof(0, 1, 0), coder.typeof(0, [2^16,1], [1,0]), coder.typeof(0, 1, 0), coder.typeof(0, 1, 0)} -o div_Events_ -report

end