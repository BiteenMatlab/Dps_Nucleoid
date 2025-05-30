% =========================================================================
%  anglevec.m  
%  Copyright © 2023-2025 Xiaofeng Dai (xiaofend@umich.edu)
%  SPDX-License-Identifier: GPL-3.0-or-later
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation, either version 3 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program (LICENSE file in the repository root).
%  If not, see <https://www.gnu.org/licenses/>.
%
%  Tested with: MATLAB R2024a and R2022a
% =========================================================================
%
% ANGLEVEC  Compute the polar angle of vector Y relative to vector X in 2‑D.
%
%   THETA = ANGLEVEC(X, Y) returns the angle THETA (in radians, range
%   [0, 2*pi)) measured counter‑clockwise from reference vector X to target
%   vector Y.
%
%   Inputs
%   ------
%     X : 1×2 or 2×1 double
%         Reference vector.
%     Y : 1×2 or 2×1 double
%         Target vector.
%
%   Output
%   ------
%     THETA : double
%         Angle between X and Y expressed in radians in [0, 2*pi).
%
%   Notes
%   -----
%   * Both X and Y must be non‑zero vectors.
%   * The function works strictly in 2‑D; additional components are ignored.
%
%   Example
%   -------
%     theta = anglevec([1 0], [0 1]);  % returns pi/2
%
function [theta] = anglevec(x, y)
    cos_val = dot(x, y) / (norm(x) * norm(y));

    % Map arccos result to full 0–2π range based on the quadrant of Y
    if y(2) < 0
        theta = 2*pi - acos(cos_val);
    elseif y(2) > 0
        theta = acos(cos_val);
    else
        if y(1) >= 0
            theta = 0;
        elseif y(1) < 0
            theta = pi;
        end
    end
end
