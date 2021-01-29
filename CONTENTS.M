% Fuzzy Logic Toolbox.
% Version 1.0, 1-19-95
% Copyright (c) 1994-95 by The MathWorks, Inc.
% $Revision: 1.13 $  $Date: 1995/02/17 13:08:10 $
%
% GUI editors
%   fuzzy      - Basic FIS editor.
%   mfedit     - Membership function editor.
%   ruleedit   - Rule editor and parser.
%   ruleview   - Rule viewer and fuzzy inference diagram.
%   surfview   - Output surface viewer.
%
% Membership functions.
%   dsigmf     - Difference of two sigmoid membership functions.
%   gauss2mf   - Two-sided Gaussian curve membership function.
%   gaussmf    - Gaussian curve membership function.
%   gbellmf    - Generalized bell curve membership function.
%   pimf       - Pi-shaped curve membership function.
%   psigmf     - Product of two sigmoid membership functions.
%   smf        - S-shaped curve membership function.
%   sigmf      - Sigmoid curve membership function.
%   trapmf     - Trapezoidal membership function.
%   trimf      - Triangular membership function.
%   zmf        - Z-shaped curve membership function.
%
% Command line FIS functions
%   addmf      - Add membership function to FIS
%   addrule    - Add rule to FIS.
%   addvar     - Add variable to FIS.
%   defuzz     - Defuzzify membership function.
%   evalfis    - Perform fuzzy inference calculation.
%   evalmf     - Generic membership function evaluation.
%   gensurf    - Generate FIS output surface.
%   getfis     - Get fuzzy system properties.
%   mf2mf      - Translate parameters between functions.
%   mfstrtch   - Stretch membership function.
%   newfis     - Create new FIS.
%   parsrule   - Parse fuzzy rules.
%   plotfis    - Display FIS input-output diagram.
%   plotmf     - Display all membership functions for one variable.
%   readfis    - Load FIS from disk.
%   rmmf       - Remove membership function from FIS.
%   rmvar      - Remove variable from FIS.
%   setfis     - Set suzzy system properties.
%   showfis    - Display annotated FIS.
%   showrule   - Display FIS rules.
%   writefis   - Save FIS to disk.
%
% Advanced techniques
%   anfis      - Training routine for Sugeno-type FIS (MEX only).
%   fcm        - Find clusters with fuzzy c-means clustering.
%   genfis1    - Generate FIS matrix using generic method.
%   genfis2    - Generate FIS matrix using subtractive clustering.
%   subclust   - Estimate cluster centers with subtractive clustering.

% Miscellaneous functions
%   combine    - Concatenate matrices of varying size.
%   discfis    - Discretize a fuzzy inference system.
%   findrow    - Find the rows of a matrix that match the input string.
%   genparam   - Generates initial premise parameters for ANFIS learning.
%   evalmmf    - For multiple membership functions evaluation.
%   nextline   - Return next line of a text files. 
%   probor     - Probabilistic OR.
%   sugmax     - Maximum output range for a Sugeno system.
%
% GUI helper files
%   cmfdlg     - Add customized membership function dialog.
%   cmthdlg    - Add customized inference method dialog.
%   fisgui     - Generic GUI handling for the Fuzzy Logic Toolbox
%   mfdlg      - Add membership function dialog.
%   popundo    - Pull the last change off the undo stack.
%   pushundo   - Push the current FIS data onto the undo stack.
%   savedlg    - Save before closing dialog.
%   statmsg    - Display messages in a status field.
%   updtfis    - Update Fuzzy Logic Toolbox GUI tools.
%   wsdlg      - Open from/save to workspace dialog.
%
% Helper functions
%   fnanmax    - NaN protected maximum.
%   fnanmin    - NaN protected minimum.
%   frot3d     - Track mouse motion with rotating cube.
