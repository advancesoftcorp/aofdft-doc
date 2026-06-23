.. _intro:

================
概要
================

AOF-DFTの計算機能は、Pythonモジュール\ `ASE (Atomic Simulation Environment) <https://ase-lib.org/>`_\ の\ `Calculator <https://ase-lib.org/ase/calculators/calculators.html>`__\ クラスを継承したAOFDFTCalculatorとして、PyTorchにより実装されています。

このマニュアルではASE自体の説明には深入りせず、AOFDFTCalculator独自の使用方法を中心に説明します。ASE自体の使い方については公式のドキュメントやウェブ上の解説をご参照ください。

.. _example:

使用例
======

.. code-block:: python

 # Calculatorをインポート
 from aofdft.calculator import AOFDFTCalculator
 from ase.build         import bulk
 from ase.io            import read

 # Atomsオブジェクトを作成
 atoms = bulk("Si", crystalstructure="diamond", a=5.43)
 # ファイルから読み込む場合
 # atoms = read("si.cif")

 # Calculatorオブジェクトを設定
 atoms.calc = AOFDFTCalculator(
     kin_type  = "AS26",
     kin_model = "Crystal26",
     vps_dir   = "path/to/DFT_DATA19/VPS", # 実際の環境に合わせてpathを指定
     pao_dir   = "path/to/DFT_DATA19/PAO", # 実際の環境に合わせてpathを指定
 )

 # Atomsオブジェクトのメソッドを呼び出すと計算が行われる
 energy = atoms.get_potential_energy()
 forces = atoms.get_forces()
 
 # 出力
 print(f"\nTotal energy: {energy:.6f} eV")
 print("Forces on atoms (eV/Å):")
 print(forces)

exapmles
===========

:file:`examples` フォルダに使用例のPythonスクリプトがあります。

 :file:`si_aofdft.py`
  Si結晶のSCF計算により、トータルエネルギーと原子ごとの力を求めます。
 :file:`fe_spin.py`
  Fe結晶のSCF計算により、原子ごとのスピンを求めます。
 :file:`c2h6_relax.py`
  孤立エタン分子の構造最適化計算およびポテンシャルエネルギー曲線の計算を実行します。
 :file:`gaas_dope.py`
  As欠陥をもつGaAs結晶で、中性/電子ドープ時の原子ごとの電荷を計算し、Gaへのドープ電子の局在化の様子を調べます。
 :file:`band_gap.py`
  半導体材料に対して、ホール/電子のドープを行い、トータルエネルギーの変化からバンドギャップを求めます。
 :file:`large_system.py`
  AOF-DFTの :math:`O(N)` という低い計算コストを生かし、大規模な系に対してSCF計算を行います。
  