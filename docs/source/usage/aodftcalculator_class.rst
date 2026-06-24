.. _aodftcalculator_class:

=========================
AOFDFTCalculator
=========================

:py:class:`aofdft.calculator.AOFDFTCalculator` クラスの説明です。

継承元のCalculatorクラスについては\ `ASEのドキュメント <https://ase-lib.org/development/calculators.html>`_\ を参照してください。

.. _aodftcalculator_constructor:

コンストラクタの引数
=====================

:py:class:`AOFDFTCalculator` オブジェクト作成時に指定する引数です。

.. code-block:: python

 calculator = AOFDFTCalculator(
     kin_type  = "AS26",
     kin_model = "Crystal26",
     vps_dir   = "path/to/DFT_DATA19_AS/VPS", # 実際の環境に合わせてpathを指定
     pao_dir   = "path/to/DFT_DATA19_AS/PAO", # 実際の環境に合わせてpathを指定
     e_cut     = 150 * Hartree # ase.units.Hartreeで150 HartreeをeVに換算
 )

.. _aodftcalculator_output:

出力
----------------

.. describe:: console

 :type: bool
 :デフォルト: True

 コンソールにログを出力するかどうかの設定です。

.. describe:: logging_file
    
 :type: None | str
 :デフォルト: None

 ログファイル名です。 ``None`` に設定するとログをファイルに出力しません。

.. describe:: population_file

 :type: None | str
 :デフォルト: None

 原子ごとの軌道占有数を出力するファイル名です。 ``None`` に設定すると出力しません。

.. describe:: wavefunc_file

 :type: None | str
 :デフォルト: None

 原子ごとの波動関数を出力するファイル名です。 ``None`` に設定すると出力しません。

.. _aodftcalculator_kinetic:

運動エネルギー汎関数
--------------------

.. describe:: kin_type

 :type: str
 :デフォルト: AS26

 AOF-DFT計算に使用する運動エネルギー汎関数を指定します。
 
 * ``"AS26"`` : AdvanceSoft26汎関数を使用します。
 * ``"TFvW"`` : 従来汎関数のThomas-Fermi-von Weizsäcker汎関数を使用します。
 * ``"LKT"``  :  従来汎関数のLuo-Karasiev-Trickey汎関数を使用します。

 .. hint::
     ``"TFvW"`` における、TF成分に対するvW成分の割合のデフォルトは1/5です。
     ``"TF1/5vW"``, ``"TF0.8vW"``, ``"TF"``, ``"vW"`` などの形式で成分を指定することが可能です。

.. describe:: kin_model

 :type: str | None
 :デフォルト: None

 AdvanceSoft26汎関数を使用する際、モデルを指定します。

 指定できる値は ``None``, ``"Crystal26"``, ``"Molecule26"``, ``"Molecule26-large"`` のいずれかです。
 ``None`` を指定した場合にはCrystal26モデルが使用されます。

.. describe:: kin_coef_tf

 :type: float
 :デフォルト: 1.0

 ``kin_type`` に ``"TFvW"`` と指定した際に、TF成分の係数を指定します。

.. describe:: kin_coef_tf

 :type: float
 :デフォルト: 0.2

 ``kin_type`` に ``"TFvW"`` と指定した際に、vW成分の係数を指定します。

.. _aodftcalculator_vps_pao:

擬ポテンシャル・擬原子軌道
----------------------------

.. describe:: vps_dir

 :type: str
 :デフォルト: DFT_DATA19_AS/VPS

 擬ポテンシャル(VPS)ファイルのあるフォルダパスを指定します。

.. describe:: pao_dir

 :type: str
 :デフォルト: DFT_DATA19_AS/PAO

 擬原子軌道(PAO)ファイルのあるフォルダパスを指定します。

.. describe:: vps_names

 :type: dict[str]
 :デフォルト: aofdft.calculator.default_files.VPS_DEFAULT

 元素ごとの擬ポテンシャル(VPS)ファイル名を指定します。ゴースト原子には ``None`` を指定します。

 ``aofdft.calculator.default_files`` に交換相関汎関数ごとに定義されているプリセット(``VPS_LDA``, ``VPS_GGA``)をインポートし、設定することができます。なお、 ``VPS_DEFAULT`` は ``VPS_GGA`` に設定されています。

 .. hint::
  プリセットは以下のように定義されています。
   * アドバンスソフト改修版の擬ポテンシャル対応元素 : ``*26_as.vps`` を使用。
   * Cu, Zn : OpenMXが提供するソフト擬ポテンシャル（``*19S.vps``）を使用。
   * それ以外 : OpenMXが提供する擬ポテンシャル（``*19.vps``）を使用。

.. describe:: pao_names

 :type: dict[str]
 :デフォルト: aofdft.calculator.default_files.PAO_DEFAULT

 元素ごとの擬原子軌道(PAO)ファイル名を指定します。
 
 ``aofdft.calculator.default_files`` に定義されているプリセット(``PAO_MINI``, ``PAO_MINI_AND_POLE``, ``PAO_OMX_QUICK``, ``PAO_OMX_STANDARD``, ``PAO_OMX_PRECISE``)をインポートし、設定することができます。基底関数のプリセット(``BASIS_*``)に対応するプリセットを使用することが推奨されます。なお、 ``PAO_DEFAULT`` は ``PAO_MINI`` に設定されています。
 
 .. hint::
  プリセットは以下のように定義されています。
   * アドバンスソフト改修版の擬ポテンシャル対応元素 : 対応する ``*_as.pao`` を使用。
   * Cu, Zn : OpenMXが提供するソフト擬ポテンシャルに対応する ``*S.pao`` を使用。
   * それ以外 : OpenMXが提供する擬ポテンシャルに対応する ``*.pao`` を使用。

.. describe:: basis

 :type: dict[str]
 :デフォルト: aofdft.calculator.default_files.BASIS_DEFAULT

 元素ごとの基底関数の割り当て（e.g. ``"s1p1"``, ``"s2p2d1"``）を指定します。
 
 ``aofdft.calculator.default_files`` に定義されているプリセット(``BASIS_MINI``, ``BASIS_MINI_AND_POLE``, ``BASIS_OMX_QUICK``, ``BASIS_OMX_STANDARD``, ``BASIS_OMX_PRECISE``)をインポートし、設定することができます。なお、 ``BASIS_DEFAULT`` は ``BASIS_MINI`` に設定されています。

 .. hint::
  プリセットは以下のように定義されています。
   * ``BASIS_MINI`` : 必要最小限の基底セット。
   * ``BASIS_MINI_AND_POLE`` : 必要最小限の基底セットに分極を追加。
   * ``BASIS_OMX_*`` : `OpenMXの推奨値 <https://www.openmx-square.org/vps_pao2019/>`_ に基づいた基底セット。

.. _aodftcalculator_calc_params:

基本条件
----------------

.. describe:: e_cut

 :type: float
 :デフォルト: 150 * Hartree

 電子密度のカットオフエネルギーをeV単位で指定します。デフォルト値は、150 Hartree ~ 4082 eV です。 ``n_grids`` に ``None`` 以外を指定した場合はそちらが優先されます。

.. describe:: n_grids

 :type: int | tuple[int] | list[int] | torch.Tensor[int] | None
 :デフォルト: None

 電子密度のグリッド数の設定です。a, b, c方向のグリッド数を ``[na, nb, nc]`` のように指定します。 ``int`` で指定した場合、各方向に同じグリッド数を設定します。 ``None`` を指定すると、 ``e_cut`` に基づいて決定されます。

.. describe:: xc_type

 :type: str
 :デフォルト: PBE

 交換相関汎関数の種類です。 ``"LDA"`` または ``"PBE"`` が使用可能です。

.. describe:: xc_pcc

 :type: bool
 :デフォルト: True

 交換相関汎関数の計算で部分内殻補正(Partial Core Correction, PCC)を使うかどうかの設定です。

.. describe:: total_charge

 :type: float
 :デフォルト: 0.0

 系の正味の電荷です。系が全体としてイオン化している場合に設定します。例えば、中性の系に対して電子を1つドープする場合は-1.0に設定します。

.. describe:: smearing

 :type: str
 :デフォルト: fermi

 Smearingの方法を設定します。 ``"gauss"`` (ガウス関数)、 ``"m-p"`` (Methfessel-Paxton)、 ``"m-v"`` (Marzari-Vanderbilt)、 ``"fermi"`` (Fermi-Dirac)が指定できます。

.. describe:: degauss

 :type: float
 :デフォルト: 0.02 * Hartree

 Smearingの幅をeV単位で指定します。

.. describe:: without_TS

 :type: bool
 :デフォルト: False

 Smearingに由来する自由エネルギーの低下分（エントロピー補正） :math:`-TS` を全エネルギーから差し引くかを指定します。

.. describe:: max_cell_strain

 :type: float
 :デフォルト: 0.05

 同じCalculatorオブジェクトで複数のSCF計算を行う場合（MDなど）、セル変形の指標がこの値より大きければFFTグリッドを再定義します。

 変形の指標は、初回または前回更新時のセル行列を :math:`A_\mathrm{old}` 、現在のセル行列を :math:`A_\mathrm{new}` とした際の、 :math:`A_\mathrm{new}A_\mathrm{old}^{-1} - I` の全成分の2乗和の平方根です。

スピン
----------------

.. describe:: spin_type

 :type: None | str
 :デフォルト: non-polarized

 スピン偏極の取り扱いを指定します。 ``None`` または ``"non-polarized"`` でスピン偏極なし、 ``"polarized"`` でスピン偏極あり(collinear)の計算を行います。
 
 スピン偏極ありの計算で原子ごとの初期スピンを指定する場合は、 ``atoms.arrays["spin"]`` に全原子の初期スピンのリスト(``list[float]``)を代入します。

.. describe:: total_spin

 :type: float | None
 :デフォルト: None

 スピン偏極あり(collinear)の計算でスピン偏極を固定する場合に、系の正味のスピン偏極を指定します。 ``None`` を指定すると固定しません。

.. describe:: ave_j

 :type: bool
 :デフォルト: True

 :math:`j`\ 依存型擬ポテンシャルのプロジェクターを、\ :math:`j`\ の縮退度を重みとして平均化することで、半相対論的（スカラー相対論的）擬ポテンシャルに変換するかどうかの設定です。 ``False`` は現行のバージョンでは対応していません。

.. _aodftcalculator_scf:

SCF計算条件
-------------

.. describe:: scf_style

 :type: None | str
 :デフォルト: None

 SCF計算条件(``mix_beta``, ``mix_nstored``, ``mix_precond``, ``noisy_precond``)の値のプリセットです。

 バルク結晶では ``"bulk"`` 、磁性体では ``"magnetic"`` 、分子では ``"molecule"`` を使用することが推奨されます。 ``None`` を指定すると、その他の計算条件に基づいて、
 ``"bulk"``, ``"magnetic"``, ``"molecule"`` または「各条件のデフォルト値を使用」のいずれかが自動で選択されます。

.. describe:: scf_must_conv

 :type: bool
 :デフォルト: False

 SCF計算が収束しない場合に例外(``RuntimeError``)を発生させるかどうかを指定します。

.. describe:: max_iter

 :type: int
 :デフォルト: 500

 SCF計算の繰り返し回数の最大値を指定します。

.. describe:: conv_thr

 :type: float
 :デフォルト: 1.0e-6 * Hartree

 エネルギーの収束条件の閾値をeV単位で指定します。

.. describe:: init_rho

 :type: None | str
 :デフォルト: atomic

 電子密度の初期値の計算方法を設定します。手法としては ``"atomic"`` （孤立原子の電子密度の重ね合わせ）または ``"density_matrix"`` （密度行列から計算）が指定できます。
 
 電子密度の初期値をプロパティ ``rho`` に直接設定する場合は、 ``None`` とします。

.. describe:: mix_method

 :type: str
 :デフォルト: pulay

 電子密度を更新するときの混合法の設定です。 ``"simple"`` （単純な線形混合）または ``"pulay"`` が指定できます。

.. describe:: mix_beta

 :type: float
 :デフォルト: 0.2

 電子密度を更新するときの混合率です。デフォルト値は0.2ですが、この値は ``scf_style`` の値に応じて変更される場合が有ります。 ``mix_beta`` の値を直接指定した場合はそちらが優先されます。

.. describe:: mix_nstored

 :type: int
 :デフォルト: 16

 電子密度の混合のために保存しておく履歴数です。デフォルト値は16ですが、この値は ``scf_style`` の値に応じて変更される場合が有ります。 ``mix_nstored`` の値を直接指定した場合はそちらが優先されます。

.. describe:: mix_precond

 :type: None | str
 :デフォルト: None

 電子密度を更新するときの前処理の方法です。 ``"TF"`` （Thomas-Fermi）または ``None`` (前処理なし)が指定できます。デフォルト値は ``None`` ですが、この値は ``scf_style`` の値に応じて変更される場合が有ります。 ``mix_precond`` の値を直接指定した場合はそちらが優先されます。

.. describe:: mix_qTF

 :type: None | float
 :デフォルト: None

 ``mix_precond`` に ``"TF"`` を指定した場合に使用する波数を1/Å単位で指定します。 ``None`` の場合自動的に決定されます。

.. describe:: noisy_precond

 :type: None | str
 :デフォルト: 2/3

 機械学習運動エネルギー汎関数の汎関数微分に一般に含まれることが知られている高周波ノイズを除去するためのPreconditioning演算子を指定します。
 
 使用可能なPreconditioning演算子は ``"gaussian"``, ``"lorentz"``, ``"teter"``,  ``"damping"``, ``"2/3"`` です。
 Preconditioning演算子を使用しない場合は ``None`` を指定します。

 デフォルト値は ``None`` ですが、この値は ``scf_style`` の値に応じて変更される場合が有ります。 ``noisy_precond`` の値を直接指定した場合はそちらが優先されます。

.. describe:: noisy_r_cut

 :type: None | float
 :デフォルト: 0.5 * Bohr

 ``noisy_precond`` で指定したPreconditioning演算子のカットオフ半径をÅ単位で指定します。

.. _aodftcalculator_hardware:

ハードウェア
--------------
.. describe:: device

 :type: str | torch.device
 :デフォルト: cpu

 PyTorchによる計算を行うデバイスを指定します。CPUを使用する場合は ``"cpu"``, GPUを使用する場合は ``"cuda"`` と指定します。
 
 複数のGPUがある環境で使用するGPUを指定するには、 ``nvidia-smi -L`` でデバイスIDを取得し、 ``"cuda:1"`` などと指定します。

.. describe:: num_threads

 :type: None | int
 :デフォルト: None

 PyTorchによる計算のOpenMPスレッド並列数を指定します。 ``None`` の場合、環境変数 ``OMP_NUM_THREADS`` が設定されていればその値を、設定されていなければシステムの論理コア数の値を使用します。

.. _aodftcalculator_property:

プロパティ
==========

``AOFDFTCalculator`` オブジェクトから値を取得または設定します。

.. code-block:: python

 energy = calculator.total_energy # トータルエネルギーを取得

 calculator.device = "cuda"       # デバイスを設定

.. py:property:: device

 :type: torch.device

 PyTorchの計算を行うデバイスの設定です。変更するとメンバーのオブジェクトをそのデバイスに移動します。設定時は ``str`` も使用可能です。

.. py:property:: rho

 :type: torch.Tensor

 電子密度(Bohr\ :sup:`-3`)です。形状は ``(n_rho, na, nb, nc)`` です。
 ``n_rho`` の値は、スピン偏極なしの場合は1、スピン偏極あり(collinear)の場合は2となります。
 ``rho[0]`` が全電子密度、 ``rho[1]`` がスピン密度に相当します。

 計算前に設定すると初期電子密度として使用されます。この時、 ``torch.Tensor(n_rho, na, nb, nc)`` , ``torch.Tensor(na, nb, nc)``, ``np.ndarray(n_rho, na, nb, nc)``, ``np.ndarray(na, nb, nc)``, ``list``, ``tuple`` のいずれかの形式で設定が可能です。設定した初期電子密度のグリッドとAOFDFTCalculatorのグリッドが一致しない場合、後者への補間が実行されます。

.. py:property:: total_energy

 :type: float

 全エネルギー(eV)です。

.. py:property:: e_fermi

 :type: float

 フェルミエネルギー(eV)です。polarizedの場合、アップスピンとダウンスピンのフェルミエネルギーの平均値を返します。

.. py:property:: e_fermi_up

 :type: float

 アップスピンのフェルミエネルギー(eV)です。

.. py:property:: e_fermi_dw

 :type: float

 ダウンスピンのフェルミエネルギー(eV)です。

.. py:property:: smeared_energy

 :type: float

 Smearingに由来する自由エネルギーの低下分（エントロピー補正） :math:`-TS` (eV)です。

.. py:property:: scf_energy_err

 :type: float

 SCF計算のエネルギーの誤差(eV)です。

.. py:property:: scf_converged

 :type: bool

 SCF計算が収束しているかどうかです。

.. py:property:: total_magmom

 :type: float

 全磁気モーメントです。

.. py:property:: absolute_magmom

 :type: float

 絶対磁気モーメントです。
