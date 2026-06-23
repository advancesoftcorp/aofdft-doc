.. _theory:

============
理論
============

Advance/OF-DFTに実装されているAtomic Orbital Facilitated DFT (AOF-DFT)と、それに関連する手法について、理論を解説します。

.. _theory_ofdft:

Orbital-Free DFT (OF-DFT)
==========================

密度汎関数理論(Density Functional Theory, DFT)は、系の電子密度 :math:`\rho(\mathbf{r})` の汎関数としてエネルギー :math:`E[\rho]` が与えられ、エネルギーを最小化することで基底状態の電子密度が得られるというHohenberg-Kohnの定理に基づきます [#Hohenberg]_。

DFTに基づく第一原理電子状態計算の標準的な手法となっているKohn-Sham DFT (KS-DFT)では、仮想的な参照系として相互作用のないKohn-Sham系を導入し、エネルギー汎関数の運動エネルギー(Kinetic Energy)項の計算にKS系の波動関数(Kohn-Sham軌道) :math:`\psi_i` を使います [#KohnSham]_。

.. math::
   :label: eq_ksdft

   & E[\rho] = \underset{\mathrm{Kinetic}}{-\frac{1}{2}\sum_{i}\langle\psi_i\lvert\nabla^2\rvert\psi_i\rangle} + \underset{\mathrm{External\ Potential}}{E_\mathrm{ext}[\rho]} + \underset{\mathrm{Hartree}}{E_\mathrm{H}[\rho]} + \underset{\mathrm{Exchange\ Correlation}}{E_\mathrm{XC}[\rho]}

KS軌道はKohn-Sham方程式と呼ばれる方程式の固有関数であり、KS-DFTでは固有値問題を数値的に解く必要があります。これが原子数 :math:`N` に対し計算量が :math:`O(N^3)` となり、「第一原理計算が重い」と言われる理由です。

対して、運動エネルギーの計算にKS軌道を使わず(Orbital-Free)、電子密度の汎関数である運動エネルギー汎関数 :math:`T[\rho]` を用いて計算量を :math:`O(N)` に抑えよう、というのがOrbital-Free DFT (OF-DFT)の考え方です。

この考え方は実用上、とても重要なものです。例えば、対象とする系の原子数 :math:`N` が10倍になった場合を考えると、KS-DFTでは計算時間が約1000倍に跳ね上がるのに対し、OF-DFTであれば10倍程度の増加に抑えられます。この差は原子数が大きくなるほど顕著になり、KS-DFTでは実質的に不可能な大規模システムのシミュレーションもOF-DFTでは可能となります。

以下に、KS-DFTとOF-DFTに加えて、近年注目されているグラフニューラルネットワーク(GNN)力場などの機械学習力場を用いる力場法を比較します。

==================== ==================== ============================ =========================
特徴 \\ 手法                     KS-DFT               OF-DFT             力場法
==================== ==================== ============================ =========================
電子密度             あり                     あり                           なし
軌道                 あり                     なし                           なし
計算精度             高い                     汎関数に依存                   力場に依存
計算コスト           :math:`O(N^3)`           :math:`O(N)`                   :math:`O(N)`
汎用性               全元素に適用可能         擬ポテンシャルによる制約        力場に依存
==================== ==================== ============================ =========================

力場法と比較すると、OF-DFTは計算コストが低水準の :math:`O(N)` で同じでありながら、電子密度を明示的に扱うことにより、外部電場の印加や電子・ホールのドープ、仕事関数等の計算ができるという大きな特長があります。

OF-DFTは、以上のような長所をもつ一方で、その精度を左右する運動エネルギー汎関数の厳密な式は知られていません。近似や機械学習 [#XuQ]_ [#Chen]_ による運動エネルギー汎関数の研究が進められるも、実用に耐えうる計算精度・汎用性は実現されませんでした。

さらに、OF-DFTには、適用可能な擬ポテンシャルが充実していないという問題もあります。OF-DFTでは、波動関数に依存した非局所演算子が使用できないため、KS-DFT用のノルム保存擬ポテンシャルやウルトラソフト擬ポテンシャルは利用できません。局所項のみで構成された局所擬ポテンシャルを使う必要があり、例えば代表的なものの一つであるOptimized Effective Pseudo Potential [#OEPP]_ では、27種類の元素にしか対応することができません。

そのような中で、弊社独自開発の汎グラフを応用した深層学習運動エネルギー汎関数AdvanceSoft26は、その高い精度により、実用に耐えうるOF-DFT計算を実現しました。
さらに、独自にOF-DFTを拡張したAOF-DFTという手法により、一般に広く使われるKS-DFT用ノルム保存擬ポテンシャルの適用も可能としました。

.. _theory_graphical:

汎グラフによる深層学習運動エネルギー汎関数
===============================================

OF-DFTの機械学習運動エネルギー汎関数の開発において、連続的な場である電子密度に対し機械学習を行うには、特徴ベクトルをどのように抽出するかが問題になります。既報の研究では、座標 :math:`\mathbf{r}` における特徴ベクトルをあらかじめ定義しておくという方法を使っていますが、十分な精度や汎用性が担保できませんでした。

一方、機械学習力場の分野では、グラフ理論を応用して、隣接原子間の相互作用を模した学習可能な特徴ベクトルを使用するGNN力場が上手くいっています。グラフは離散的なノード・エッジから構成されますが、このような学習可能な特徴ベクトルを機械学習汎関数にも応用できないか、という考えから、弊社ではグラフを連続多変数空間に拡張したものを独自に開発し、これを汎グラフと名付けました。関数(Function)→汎関数(Functional)に倣い、グラフ(Graph)→汎グラフ(Graphical)としています。

まず、汎グラフの着想元となる、通常のグラフ上のグラフ畳み込みネットワーク(Graph Convolutional Network, GCN)について説明します。ノード :math:`i, j, ...` と、それらを繋ぐエッジを考えます。各エッジにはノード間の繋がりを表す係数 :math:`a_{ij}` を設定します。各ノードに初期値（入力） :math:`h_i^0` を与え、この値（特徴量）を更新していくことを考えます。

更新は、「隣接ノードの特徴量の集約」と「重みによる変換」の2段階で行います。

.. math::
   :label: eq_node

   & x_i^n = \sum_j a_{ij} h_j^n

.. math::
   :label: eq_weight

   & h_i^{n+1} = h_i^n + \sigma(w^nx_i^n)

:math:`\sigma` は非線形な振る舞いを表現するために使われる活性化関数です。また、 :math:`h_i^{n+1}` を :math:`h_i^n` に対する差分の形で更新する方法を残差接続と呼びます。

このままでは更新を繰り返しても特徴量を拡散させるフィルタのようにしか働きません。そこで、マルチチャンネル化を行います。特徴量をチャンネル数の次元を持つ特徴ベクトル :math:`\mathbf{h}_i` とし、更新には重み行列 :math:`W` を使います。

.. math::
   :label: eq_multi

   & \mathbf{h}_i^{n+1} = \mathbf{h}_i^n + \sigma(W^n\mathbf{x}_i^n)

特徴ベクトルの各チャンネルの混合を含めた処理が入り、この更新（畳み込み）を繰り返すことにより、複雑な処理を行えるようになります。最終的に目的の特徴ベクトル（出力）が得られるように :math:`W^n` を最適化するのが、GCNの学習ということになります。

次に、GCNを連続多変数空間上で定義された場に適用できるよう拡張することを考えます。このとき、グラフと汎グラフの対応関係は以下の表のようになります。

+-----------------------------------+----------------------------------------------+
| グラフ                            |     汎グラフ                                 |
+===================================+==============================================+
| ノード :math:`i`                  | 座標 :math:`\mathbf{r}`                      |
+-----------------------------------+----------------------------------------------+
| エッジ :math:`ij`                 | 座標の組 :math:`(\mathbf{r}, \mathbf{r}')`   |
+-----------------------------------+----------------------------------------------+
| 特徴ベクトル :math:`\mathbf{h}_i` | 場 :math:`\mathbf{h}(\mathbf{r})`            |
+-----------------------------------+----------------------------------------------+
| 隣接行列 :math:`a_{ij}`           | 隣接相関 :math:`a(\mathbf{r}, \mathbf{r}')`  |
+-----------------------------------+----------------------------------------------+
| 特徴量の集約                      | 隣接相関を積分核とする畳み込み積分           |
+-----------------------------------+----------------------------------------------+

隣接相関 :math:`a(\mathbf{r}, \mathbf{r}')` は定義上は :math:`\mathbf{R} = \mathbf{r} - \mathbf{r}'` で非ゼロの値を持つデルタ関数になりますが、数値計算を行うために、動径方向に幅を持つガウス関数で置き換えます。角度方向には球対称とし、球平均を取って距離のみの関数にします。

.. math::
   :label: eq_sphere
    
   a(\mathbf{r}, \mathbf{r}') = a\left(|\mathbf{r} - \mathbf{r}'|\right) = \int \mathrm{d}\Omega \frac{1}{\left(\sqrt{2\pi}\kappa\right)^3} \exp\left(-\frac{|\mathbf{r}-\mathbf{r}'-\mathbf{R}|^2}{2\kappa^2}\right)

半径 :math:`R` 、幅 :math:`\kappa` がパラメータとなります。種々の :math:`\{R_i, \kappa_i\}` 対に対する :math:`a_i\left(|\mathbf{r} - \mathbf{r}'|\right)` を使って特徴量を集約することで、空間全体をカバーするようなマルチチャンネル化を行ったことになります。また、畳み込み積分の距離を有限にするため、カットオフ関数 :math:`f_i` を適用します。

最終的に、汎グラフは次のように定式化されます。

.. math::
   :label: eq_graphical_x

   & x_{\mu i}^n(\mathbf{r}) = f_i \int \mathrm{d}\mathbf{r}' a_i(|\mathbf{r} - \mathbf{r}'|)h_\mu^n(\mathbf{r}')

.. math::
   :label: eq_graphical_h

   & h_\nu^{n+1}(\mathbf{r}) = h_\nu^n(\mathbf{r}) + \sigma\left(\sum_{\mu i}w_{\nu,\mu i}^n x_{\mu i}^n(\mathbf{r})\right)

:math:`\mathbf{r}` が連続のままであることに注目してください。数値計算を行う上では離散的な :math:`\mathbf{r}` （メッシュ）を使いますが、汎グラフのパラメータはメッシュの細かさに依存しません。学習時と推論時でメッシュの細かさや形が異なっていても良く、transferabilityが高いという特長があります。

この汎グラフを適用した深層学習運動エネルギー汎関数AdvanceSoft26 (AS26)の基本的なアーキテクチャは下図のようになります。汎グラフに入力する特徴ベクトルは、電子密度の勾配とラプラシアンからつくられます。

.. image:: /img/graphical.png

出力は、Thomas-Fermi (TF)モデルおよびvon Weizsäcker (vW)モデル [#XuQ]_ で計算した運動エネルギー密度 :math:`\tau(\mathbf{r})` に対する補強因子 :math:`F^\mathrm{NN}[\rho](\mathbf{r})` として使い、最終的な運動エネルギーを得ます。

.. math::
   :label: eq_TAS26

   T_\mathrm{AS26}[\rho] = \int \mathrm{d}\mathbf{r} \lbrace\tau^\mathrm{TF}(\mathbf{r})F_\mathrm{TF}^\mathrm{NN}[\rho](\mathbf{r}) + \tau^\mathrm{vW}(\mathbf{r})F_\mathrm{vW}^\mathrm{NN}[\rho](\mathbf{r})\rbrace

さらに、分子系に対しては以下の非局所のWang-Teter（WT）モデル [#XuQ]_ の項を追加します。

.. math::
   :label: eq_Twt

   \sum_{i=1}^{2 N_{k_\mathrm{F}}} \tau_{i}^\mathrm{WT}(\mathbf{r}) F_{\mathrm{WT}, i}^\mathrm{NN}(\mathbf{r})

ここで、 :math:`N_{k_\mathrm{F}}` はフェルミ波数 :math:`k_\mathrm{F}` の総数であり、Wang-Teterの運動エネルギー密度 :math:`\tau_{i}^\mathrm{WT}(\mathbf{r})` はGELU関数によって正負の成分に分離されています。

以上のようにして開発された汎グラフによる深層学習運動エネルギー汎関数は、OF-DFTにおいて、従来の運動エネルギー汎関数を大きく上回る精度と汎用性を実現しました。

.. _theory_ldmft:

局所密度行列汎関数理論 (L-DMFT)
================================

先述の通り、OF-DFTは、波動関数に依存した非局所演算子が使用できないことからKS-DFT用のノルム保存擬ポテンシャルが利用できず、適用元素が限定されます。

弊社ではこの課題を解決すべく、原子ごとの局所的な密度行列は厳密に扱い、原子間は電子密度の汎関数で計算する局在密度行列汎関数理論 (Localized Density Matrix Functional Theory, L-DMFT)という手法を開発しました。

L-DMFTは、OF-DFTをDMFTにより拡張した理論であり、基底状態のエネルギー :math:`E` を、電子密度 :math:`\rho(\mathbf{r})` だけではなく、1電子縮約密度行列 :math:`\tilde{\rho}(\mathbf{r}, \mathbf{r}')` の汎関数とします。

.. math::
   :label: eq_E_ldmft

   E[\rho, \tilde{\rho}] = \underset{\mathrm{Kinetic}}{T[\rho]} + \int\underset{\mathrm{Local\ potential}}{ d\mathbf{r} \, v_{\mathrm{loc}}(\mathbf{r}) \rho(\mathbf{r})} + \underset{\mathrm{Non-local\ potential}}{E_{\mathrm{NL}}[\tilde{\rho}]} + \underset{\mathrm{Hartree,\ Exchange\ Correlation}}{E_\mathrm{HXC}[\rho]}

:math:`v_{\mathrm{loc}}` は局所ポテンシャル、:math:`E_{\mathrm{NL}}` は非局所エネルギーです。密度行列 :math:`\tilde{\rho}(\mathbf{r}, \mathbf{r}')` は非局所エネルギー :math:`E_{\mathrm{NL}}` の計算にのみ使われるため、原子核の座標 :math:`\mathbf{R}` からみたカットオフ半径 :math:`r_\mathrm{cut}` の内側のみに限定します。

.. math::
   :label: eq_ldmft_cond1

   \tilde{\rho}(\mathbf{r}, \mathbf{r}') = 0, \quad \text{if} \quad |\mathbf{r} - \mathbf{R}| > r_\mathrm{cut} \quad \text{or} \quad |\mathbf{r}' - \mathbf{R}| > r_\mathrm{cut}

.. math::
   :label: eq_ldmft_cond2

   \tilde{\rho}(\mathbf{r}, \mathbf{r}) = \rho(\mathbf{r}), \quad \text{if} \quad |\mathbf{r} - \mathbf{R}| < r_\mathrm{cut}

非局所エネルギー :math:`E_{\mathrm{NL}}` 以外の部分は、従来のOF-DFTと同様に電子密度 :math:`\rho(\mathbf{r})` のみで計算可能です。

以上のようにして、各原子に局在化した密度行列を用いることによって、非局所演算子の計算が可能となり、KS-DFT用のノルム保存擬ポテンシャルの適用が実現します。
また、純粋なOF-DFTでは難しかったDFT+U（電子相関の補正）やスピン軌道相互作用といった局所的な物理現象の計算も実装可能となります。

さらに、従来のOF-DFTに比べて情報量および演算量は増えるものの、その量は原子数に比例する程度であり、計算コストは低水準の :math:`O(N)` に維持することができます。

.. _theory_aofdft:

Atomic Orbital Facilitated DFT (AOF-DFT)
============================================

L-DMFTを、擬原子軌道を用いて解く手法をAtomic Orbital Facilitated DFT (AOF-DFT)と呼称します。

AOF-DFTでは、L-DMFTの定義を満たすように、1電子縮約密度行列 :math:`\tilde{\rho}(\mathbf{r}, \mathbf{r}')` および電子密度 :math:`\rho(\mathbf{r})` を以下のように定義します。

.. math::
   :label: eq_reduced_rho

   \tilde{\rho}(\mathbf{r}, \mathbf{r}') = \sum_A \sum_{i,j} P_{ij}^A \chi_i^A (\mathbf{r}) \chi_j^A (\mathbf{r}')

.. math::
   :label: eq_eho

   \rho(\mathbf{r}) = \sum_A \sum_{i,j} P_{ij}^A \chi_i^A (\mathbf{r}) \chi_j^A (\mathbf{r})

ここで、:math:`\chi_i^A` は :math:`A` 番目の原子における :math:`i` 番目の擬原子軌道、:math:`P_{ij}^A` は原子内の成分のみで構成されたブロック対角密度行列です。

式 :eq:`eq_reduced_rho` , :eq:`eq_eho` を式 :eq:`eq_E_ldmft` のエネルギー汎関数 :math:`E` に代入し、以下の式 :eq:`eq_Pij` , :eq:`eq_N_conserve` で表される :math:`N` 表示可能性の条件および電子数保存則のもとで密度行列 :math:`P_{ij}^A` を変分原理にて最適化することで、基底状態を求めることができます。

.. math::
   :label: eq_Pij

   P_{ij}^A = \sum_n f_n^A C_{ni}^{A*} C_{nj}^A

.. math::
   :label: eq_N_conserve

   \sum_A \sum_i P_{ii}^A = N

ここで、:math:`f_n^A` は軌道占有数、:math:`C_{ni}^A` は擬原子軌道の展開係数であり、同一原子内で原子軌道 :math:`\chi_i^A` が規格直交化されていると仮定しました。

式 :eq:`eq_reduced_rho` , :eq:`eq_eho` , :eq:`eq_Pij` を用いて、式 :eq:`eq_E_ldmft` のエネルギー汎関数 :math:`E` の変分をとると、次のような :math:`C_{ni}^A` に対する「原子毎の」固有値問題に帰着します。

.. math::
   :label: eq_eigen

   \sum_j H_{ij}^A C_{nj}^A = \varepsilon_n C_{ni}^A

.. math::
   :label: eq_ham_aofdft

   \begin{aligned}
   H_{ij}^A = &\int d\mathbf{r} \chi_i^A (\mathbf{r}) \left[ \frac{\delta T}{\delta \rho(\mathbf{r})} + \frac{\delta E_{\mathrm{HXC}}}{\delta \rho(\mathbf{r})} + v_{\mathrm{loc}} (\mathbf{r}) \right] \chi_j^A (\mathbf{r}) \\
   &+ \sum_B \sum_k \left[ \int d\mathbf{r} \chi_i^A (\mathbf{r}) \beta_k^B (\mathbf{r}) \right] D_k^B \left[ \int d\mathbf{r}' \chi_j^A (\mathbf{r}') \beta_k^B (\mathbf{r}') \right]
   \end{aligned}

ハミルトニアン :math:`H_{ij}^A` の右辺第2項が、非局所エネルギーに相当します。:math:`\beta_k^B` は :math:`B` 番目の原子の :math:`k` 番目の射影演算子、:math:`D_k^B` は各射影演算子に対するエネルギーです。:math:`A \neq B` の場合も有限な寄与があるため計算に含めますが、これはカットオフ半径に重なりがある場合に限られるため、計算コストは低水準の :math:`O(N)` に維持されます。

原子毎の固有値方程式 (式 :eq:`eq_eigen`)を解くと同時に、電子数保存則 (式 :eq:`eq_N_conserve`)を満たすように全ての原子の軌道占有数 :math:`f_n^A` を決定し、最終的に式 :eq:`eq_Pij` の密度行列を得ます。

AOF-DFTでは、OF-DFTの場合と同様に、既存の運動エネルギー汎関数を用いると実用に耐えうる精度は担保されませんが、深層学習運動エネルギー汎関数を用いることでこの問題を解決できます。

深層学習運動エネルギー汎関数とAOF-DFTの開発により、OF-DFTの :math:`O(N)` の計算コストを維持したまま、実用に耐えうる精度で、全元素対応の電子状態計算が可能となりました。

.. _theory_split:

運動エネルギーの空間分割
========================

原子核近傍においては、価電子軌道であっても比較的に大きな振幅を持つため、運動エネルギーは非常に大きくなります。このように大きな振幅を持つ軌道に対しては、運動エネルギーを汎関数として表現するのは容易ではありません。そこでAOF-DFTでは、原子核近傍に適当な重み関数を設定しておき、重み関数の存在する部分についてのみ、汎関数だけではなく運動エネルギー演算子も用いて厳密に計算するというアプローチをとっています。

具体的には、運動エネルギー :math:`T` を、原子核近傍の運動エネルギー :math:`T_O` と、汎関数による運動エネルギー :math:`T_F` の和とします。

.. math::
   :label: eq_t_total

   T = T_O + T_F

原子核近傍の運動エネルギー :math:`T_O` は以下のように定義します。

.. math::
   :label: eq_to_integral

   T_O = \sum_B \frac{1}{2} \int d\mathbf{r}' \int d\mathbf{r} \, W_B(\mathbf{r}) \delta(\mathbf{r}-\mathbf{r}') \nabla_\mathbf{r} \cdot \nabla_{\mathbf{r}'} \tilde{\rho}(\mathbf{r},\mathbf{r}')

ここで、 :math:`W_B(\mathbf{r})` は原子 :math:`B` に局在化した重み関数であり、原子核近傍で1、遠方で0の値をとります。
式 :eq:`eq_reduced_rho` を用いて式 :eq:`eq_to_integral` 展開すると、次のようになります。

.. math::
   :label: eq_to_expanded

   T_O = \sum_B \sum_A \sum_{i,j} \frac{1}{2} \int d\mathbf{r} \, W_B(\mathbf{r}) P_{ij}^A \nabla_\mathbf{r} \chi_i^A(\mathbf{r}) \cdot \nabla_\mathbf{r} \chi_j^A(\mathbf{r})


一方、運動エネルギー汎関数の寄与 :math:`T_F` は、重み関数 :math:`W_B(\mathbf{r})` と運動エネルギー密度 :math:`\tau(\mathbf{r})` を用いて、以下のように定義します。

.. math::
   :label: eq_tf

   T_F = \int d\mathbf{r} \left( 1 - \sum_B W_B(\mathbf{r}) \right) \tau(\mathbf{r})

例えば、運動エネルギー汎関数としてAS26を用いる場合、 :math:`\tau(\mathbf{r})` は以下のようになります。

.. math::
   :label: eq_tauAS26

   \tau(\mathbf{r}) = \tau^\mathrm{TF}(\mathbf{r})F_\mathrm{TF}^\mathrm{NN}[\rho](\mathbf{r}) + \tau^\mathrm{vW}(\mathbf{r})F_\mathrm{vW}^\mathrm{NN}[\rho](\mathbf{r})

現行のバージョンのAOF-DFTでは、以下で定義される重み関数 :math:`W_B(r)` を使用しています。

.. math::
   :label: eq_WB

   W_B(r) = 
   \begin{cases} 
   \frac{1}{2} \left( 1 + \cos\left( \pi \frac{r}{r_{B}} \right) \right) & (0 \le r < r_{B}) \\
   0.0 & (r \ge r_{B})
   \end{cases}

ここで、 :math:`r` は原子 :math:`B` の中心からの距離であり、 :math:`r_B` の値としては、原子 :math:`B` の共有結合半径の1.2倍の値を用いています。

.. _theory_precond:

Preconditioning演算子
===================================

一般に、機械学習運動エネルギー汎関数の汎関数微分 :math:`\delta T / \delta \rho` は、高周波領域にて不安定である(ノイズを含む)ことが知られています [#Noise]_ 。汎関数微分 :math:`\delta T / \delta \rho` は電子密度を更新する際に用いるポテンシャルに相当するため、機械学習運動エネルギー汎関数を用いるOF-DFTのSCF計算は不安定となります。

AOF-DFTにおいても同様に存在するこの問題を解決すべく、KS-DFTにおける電荷密度混合法や波動関数対角化にも使用されるPreconditioning演算子 :math:`K` を導入しました。

.. math::
   :label: eq_rho_update

   \rho_{n+1}(\mathbf{g}) = \rho_n(\mathbf{g}) + K(\mathbf{g}) \delta\rho(\mathbf{g})

ただし、AOF-DFTにおけるPreconditioning演算子は高周波成分を除去する必要があるため、KS-DFTにおけるKerker演算子などとは異なる定義式が要求されます。そこで、具体的には、以下の5つの定義を用意しました。

**Gaussian Preconditioner** : :math:`K(\mathbf{g}) = \exp \left[ -\frac{g^2 \sigma^2}{2} \right]`
 標準偏差 :math:`\sigma` のガウス関数による、位置 :math:`\mathbf{r}` における :math:`\delta \rho` の球平均に相当します。
**Lorentz Preconditioner** : :math:`K(\mathbf{g}) = \frac{g_0^2}{g_0^2 + g^2}` 
 Gaussian Preconditionerの指数関数版に相当します。 :math:`g_0` は波数ベクトルのダンピング因子です。
**Teter Preconditioner** : :math:`K(\mathbf{g}) = \frac{27 + 18x + 12x^2 + 8x^3}{27 + 18x + 12x^2 + 8x^3 + 16x^4} \ \text{where} \ x = \frac{g^2}{g_0^2}`
 VASPのRMM-DIISなどで波動関数に対して利用される演算子です [#Teter]_。
**Damping Preconditioner** : :math:`K(\mathbf{g}) = \begin{cases} 1 - 3\left(\frac{g}{g_{\max}}\right)^2 + 2\left(\frac{g}{g_{\max}}\right)^3 & (g \le g_{\max}) \\ 0 & (g > g_{\max}) \end{cases}`
 TD-DFTやRISMで使用されるダンピング関数です [#Damp]_ 。
**Two-Thirds Preconditioner** : :math:`K(\mathbf{g}) = \begin{cases} 1 & (g \le g_{\max}) \\ 0 & (g > g_{\max}) \end{cases} \ \text{where} \ g_{\max} = \frac{2}{3} \sqrt{2 E_{\text{cut}}}`
 電子密度のカットオフエネルギー :math:`E_{\text{cut}}` に基づく最大波数の2/3をカットオフ波数 :math:`g_{\max}` とする演算子です [#Orszag]_ 。


.. _theory_reference:

参考文献
===================================

.. [#Hohenberg] P\. Hohenberg and W\. Kohn, Phys. Rev. 136 B864 (1964)
.. [#KohnSham]  W\. Kohn and L\. J\. Sham,  Phys. Rev. 140 A1133 (1965)
.. [#XuQ]       Xu Q et al.,                WIREs Comput Mol Sci. 14(3) e1724 (2024)
.. [#Chen]      Liang Sun and Mohan Chen,   Electron. Struct. 6 045006 (2024)
.. [#OEPP]      Mi W et al.,                J. Chem. Phys. 144 134108 (2016)
.. [#Noise]     R\. Meyer et al.,           J\. Chem. Theory Comput. 16 5685-5694 (2020)
.. [#Teter]     Michael P\. Teter et al.,   Phys. Rev. B 40 12255 (1989)
.. [#Damp]      S\. Hagiwara et al.,        Phys. Rev. Materials 6 093802 (2022)
.. [#Orszag]    Steven A\. Orszag,          J\. Atmos. Sci. 28 1074 (1971)
