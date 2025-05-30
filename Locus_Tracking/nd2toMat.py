# =========================================================================
#  nd2toMat.py
#
#  Copyright © 2023-2025 Xiaofeng Dai (xiaofend@umich.edu)
#  SPDX-License-Identifier: GPL-3.0-or-later
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program (LICENSE file in the repository root).
#  If not, see <https://www.gnu.org/licenses/>.
# =========================================================================
"""
Convert **ND2** image to MATLAB `.mat` files (v7) containing variable `mov`.

"""

import nd2
import numpy as np
from scipy.io import savemat

# import nd2 file list for conversion
file_list = open('nd2_path_list.txt','r')
nd2_list = file_list.readlines()
nd2_list = [x.strip() for x in nd2_list]
# print(nd2_list)
# print(nd2_list[0])

for nd2_file_path in nd2_list:
    my_array = nd2.imread(nd2_file_path)
    mat_file_path = nd2_file_path
    mat_file_path = mat_file_path[0:-3]
    mat_file_path = mat_file_path + 'mat'
    savemat(mat_file_path, {'mov': my_array})