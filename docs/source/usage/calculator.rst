.. _calculator:

=========================
AOF-DFT計算
=========================

AOF-DFTの計算機能は、Pythonモジュール\ `ASE (Atomic Simulation Environment) <https://ase-lib.org/>`_\ の\ `Calculator <https://ase-lib.org/ase/calculators/calculators.html>`__\ クラスを継承した ``AOFDFTCalculator`` として、PyTorchにより実装されています。

基本的な使い方は既存の ``Calculator`` サブクラスと同様です。 ``AOFDFTCalculator`` オブジェクトを作成し、 ``Atoms`` オブジェクトの ``calc`` プロパティに設定して、 ``Atoms`` オブジェクトの計算メソッドを呼び出します。
また、 ``AOFDFTCalculator`` は、OpenMP並列及びGPUでの計算に対応しています。

.. code-block:: python

 from aofdft.calculator import AOFDFTCalculator
 from ase.build         import bulk
 from ase.units         import Hartree

 atoms = bulk("Si", crystalstructure="diamond", a=5.43)

 atoms.calc = AOFDFTCalculator(
     kin_type  = "AS26",
     kin_model = "Crystal26",
     vps_dir   = "path/to/DFT_DATA19_AS/VPS", # 実際の環境に合わせてpathを指定
     pao_dir   = "path/to/DFT_DATA19_AS/PAO", # 実際の環境に合わせてpathを指定
     e_cut     = 150 * Hartree # ase.units.Hartreeで150 HartreeをeVに換算
 )

 energy = atoms.get_potential_energy()

.. _calculator_input:

入力
====

系の構造を ``Atoms`` オブジェクトとして、計算の設定を ``AOFDFTCalculator`` のコンストラクタの引数として渡します。

ここでは主要な設定項目を示します。すべての設定項目は\ :ref:`AOFDFTCalculator#コンストラクタの引数 <aodftcalculator_constructor>`\ を参照してください。

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

.. describe:: e_cut

 :type: float
 :デフォルト: 150 * Hartree

 電子密度のカットオフエネルギーをeV単位で指定します。デフォルト値は、150 Hartree ~ 4082 eV です。 ``n_grids`` に ``None`` 以外を指定した場合はそちらが優先されます。

.. describe:: xc_type

 :type: str
 :デフォルト: PBE

 交換相関汎関数の種類です。 ``"LDA"`` または ``"PBE"`` が使用可能です。

.. describe:: spin_type

 :type: None | str
 :デフォルト: non-polarized

 スピン偏極の取り扱いを指定します。 ``None`` または ``"non-polarized"`` でスピン偏極なし、 ``"polarized"`` でスピン偏極あり(collinear)の計算を行います。
 
 スピン偏極ありの計算で原子ごとの初期スピンを指定する場合は、 ``atoms.arrays["spin"]`` に全原子の初期スピンのリスト(``list[float]``)を代入します。

.. describe:: scf_style

 :type: None | str
 :デフォルト: None

 SCF計算条件(``mix_beta``, ``mix_nstored``, ``mix_precond``, ``noisy_precond``)の値のプリセットです。

 バルク結晶では ``"bulk"`` 、磁性体では ``"magnetic"`` 、分子では ``"molecule"`` を使用することが推奨されます。 ``None`` を指定すると、その他の計算条件に基づいて、
 ``"bulk"``, ``"magnetic"``, ``"molecule"`` または「各条件のデフォルト値を使用」のいずれかが自動で選択されます。

.. describe:: device

 :type: str | torch.device
 :デフォルト: cpu

 PyTorchによる計算を行うデバイスを指定します。CPUを使用する場合は ``"cpu"``, GPUを使用する場合は ``"cuda"`` と指定します。
 
 複数のGPUがある環境で使用するGPUを指定するには、 ``nvidia-smi -L`` でデバイスIDを取得し、 ``"cuda:1"`` などと指定します。

.. describe:: num_threads

 :type: None | int
 :デフォルト: None

 PyTorchによる計算のOpenMPスレッド並列数を指定します。 ``None`` の場合、環境変数 ``OMP_NUM_THREADS`` が設定されていればその値を、設定されていなければシステムの論理コア数の値を使用します。


.. _calculator_models:

学習済みモデル
==============

学習済みモデルは :file:`aofdft/deepkin/pretrained` にpthファイルとして入っています。

現行のバージョンでは、結晶を対象として学習したCrystal26、分子を対象として学習したMolecule26が利用可能です。

推論時には、計算の安定性のために、複数のモデルの平均値を最終的な出力として利用しています。Molecule26はデフォルトでは3つのモデルの平均を利用しますが、 ``kin_model`` に ``Molecule26-large`` と指定することで、モデルサイズの大きい4つ目のモデルを追加して計算を行うことができます。

.. _calculator_vps_pao:

擬ポテンシャル・擬原子軌道
============================================

AOF-DFTでは、OpenMXの提供するノルム保存擬ポテンシャル・擬原子軌道を使用可能です。
現行のバージョンではHからBiまでの、ランタノイドを除く68元素に対応しています。

ただし、局在性の高いセミコアを価電子として扱っている元素では、SCF計算の安定性・精度が不十分となるため、セミコアを取り除いた擬ポテンシャル・擬原子軌道を `ADPACK <https://www.openmx-square.org/adpack_man2.2_jp/adpack2_2_jp.html>`_ にて独自に作成しています。

その対象となる元素は、Na, Mg, K, Ca, Sc, Ti, V, Cr, Mn, Fe, Co, Ni, Ga, As, Rb, Sr, Y, Zr, Nb, Mo, Tc, Ru, Rh, Pd, Ag, In, Sn, Sb, Te, Cs, Ba, Hf, Ta, W, Re, Os, Ir, Pt, Au, Hg, Tl, Pb, Biです。ただし、Cs, Baでは5s電子についてはそのまま価電子として扱っています。

これらのアドバンスソフト改修版の擬ポテンシャル・擬原子軌道ファイルは、 ``*26_as.vps`` , ``*_as.pao`` というファイル名で提供されます。

.. _calculator_execute:

計算実行
========

Atomsオブジェクトの ``get_potential_energy()`` などのメソッドを呼び出すことで、AOF-DFT計算が実行されます。

.. _calculator_result:

結果取得
========

``get_potential_energy()`` , ``get_forces()`` などのメソッドの返り値として結果を取得します。全エネルギーは単位がeVのスカラー値、力は単位がeV/ÅのNumPy配列(原子数 :math:`\times` 3)として取得できます。

原子ごとの電荷、スピンは ``Atoms`` オブジェクトの ``atoms.arrays["charge"]``, ``atoms.arrays["spin"]`` からNumPy配列として取得できます。

また、 ``AOFDFTCalculator`` オブジェクトのプロパティからフェルミエネルギーなどの計算結果を取得できます。詳細は\ :ref:`AOFDFTCalculator#プロパティ <aodftcalculator_property>`\ を参照してください。


