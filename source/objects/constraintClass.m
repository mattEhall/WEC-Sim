%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2014 the National Renewable Energy Laboratory and Sandia Corporation
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef constraintClass<handle
    properties (SetAccess = 'public', GetAccess = 'public')%input file 
        name                    = 'NOT DEFINED'                                 % Name of the constraint used 
        loc                     = [999 999 999]                                 % Constraint location. Default = [0 0 0]        
        mooring                 = struct('initLinDispAngle',[0 0 0 0 0 0],...   % Mooring initial displacement and angle , Vector length 6.
                                         'c',          zeros(6,6), ...          % Mooring damping, 6 x 6 matrix. 
                                         'k',          zeros(6,6), ...          % Mooring stiffness, 6 x 6 matrix.
                                         'preTension', [0 0 0 0 0 0])           % Mooring preTension, Vector length 6.
        initDisp                = 0                                             % Pitch constraint only. Initial angular displacement of joint [radians]. Use with caution: frame must be rotated back before attachement to next body.
    end
    
    properties (SetAccess = 'public', GetAccess = 'public')%internal
        constraintNum           = []                                            % Constraint number
    end
    
    methods (Access = 'public')                                        
        function obj = constraintClass(name)
            % Initilization function
            obj.name = name;
        end
        
        function obj = checkLoc(obj,action)
            % Used in mask Initialization.
            % Checks if location is set and outputs a warning or error.
            switch action
              case 'W'
                if obj.loc == 999 % Because "Allow library block to modify its content" is selected in block's mask initialization, this command runs twice, but warnings cannot be displayed during the first initialization. 
                    obj.loc = [888 888 888];
                elseif obj.loc == 888
                    obj.loc = [0 0 0];
                    s1= ['For ' obj.name ': constraint.loc was changed from [9999 9999 9999] to [0 0 0]'];
                    warning(s1)
                end
              case 'E'
                try
                    if obj.loc == 999
                      s1 = ['For ' obj.name ': constraint.loc needs to be specified in the WEC-Sim input file.' ...
                        ' constraint.loc is the [x y z] location, in meters, for the pitch constraint.'];
                      error(s1)
                    end
                catch exception
                  throwAsCaller(exception)
                end
            end
        end
        
        function setInitLoc(obj, loc_at_rest, x_rot, ax_rot, ang_rot, addLinDisp)
            % function to set the initial location when having initial displacement
            % loc_at_rest: location at rest 
            % x_rot: rotation point
            % ax_rot: axis about which to rotate (must be a normal vector)
            % ang_rot: rotation angle in radians
            % addLinDisp: initial linear displacement (in addition to the displacement caused by rotation)
            loc = loc_at_rest;
            relCoord = loc - x_rot;
            rotatedRelCoord = obj.rotateXYZ(relCoord,ax_rot,ang_rot);
            newCoord = rotatedRelCoord + x_rot;
            obj.loc= newCoord + addLinDisp;
        end

        function xn = rotateXYZ(obj,x,ax,t)
            % function to rotate a point about an arbitrary axis
            % x: 3-componenet coordiantes
            % ax: axis about which to rotate (must be a normal vector)
            % t: rotation angle
            % xn: new coordinates after rotation
            rotMat = zeros(3);
            rotMat(1,1) = ax(1)*ax(1)*(1-cos(t))    + cos(t);
            rotMat(1,2) = ax(2)*ax(1)*(1-cos(t))    + ax(3)*sin(t);
            rotMat(1,3) = ax(3)*ax(1)*(1-cos(t))    - ax(2)*sin(t);
            rotMat(2,1) = ax(1)*ax(2)*(1-cos(t))    - ax(3)*sin(t);
            rotMat(2,2) = ax(2)*ax(2)*(1-cos(t))    + cos(t);
            rotMat(2,3) = ax(3)*ax(2)*(1-cos(t))    + ax(1)*sin(t);
            rotMat(3,1) = ax(1)*ax(3)*(1-cos(t))    + ax(2)*sin(t);
            rotMat(3,2) = ax(2)*ax(3)*(1-cos(t))    - ax(1)*sin(t);
            rotMat(3,3) = ax(3)*ax(3)*(1-cos(t))    + cos(t);
            xn = x*rotMat;
        end

        function listInfo(obj)
            % List constraint info
            fprintf('\n\t***** Constraint Name: %s *****\n',obj.name)
        end
    end
end