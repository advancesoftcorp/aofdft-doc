.. _install:

============
インストール
============

.. _requirement:

動作環境
========

* Python 3.10以降
* GPUを使う場合: CUDA 12.6以降（ドライババージョン560以降、Maxwell世代以降のGPU）

.. _install_procedure:

インストール手順
================

Python環境がない場合は、\ `Minicondaのページ <https://docs.conda.io/en/latest/miniconda.html>`_\ からインストーラーをダウンロードし、インストールしてください。

.. hint::
   Windowsで環境変数 ``PATH`` を変更しない設定でMinicondaをインストールした場合、以降の作業はスタートメニューからAnaconda Promptを起動して行ってください。

.. hint::
     インターネット接続にプロキシが必要な場合は、環境変数の設定等を適宜行ってください。

     .. code-block:: console
        :caption: Windows・認証なしの例

        set HTTP_PROXY=http://host:port
        set HTTPS_PROXY=http://host:port

     .. code-block:: console
        :caption: Linux・認証ありの例

        export HTTP_PROXY=http://user:pass@host:port
        export HTTPS_PROXY=http://user:pass@host:port

必要に応じ仮想環境を作成して、その中でインストールを行います。

.. code-block:: console
 :caption: conda環境での例

 conda create -n aofdft python=3.12 # 仮想環境の作成
 conda activate aofdft              # 仮想環境の有効化


準備ができたら、パッケージのフォルダに移動し、インストールコマンドを実行します。

.. code-block:: console

 pip install .

.. hint::

 ビルドに失敗する場合、ビルド済みパッケージを使うように指定することで改善する可能性があります。

 .. code-block:: console

  pip install . --only-binary :all:

GPUを使用する場合、NVIDIAドライバをインストールした上で、GPU版PyTorchをインストールします。最新版は `Get Started <https://pytorch.org/get-started>`__ 、そうでない場合は `Previous Versions <https://pytorch.org/get-started/previous-versions/>`_ を参照し、CUDAバージョンに合わせたインストールコマンドを実行してください。

.. code-block:: console
 :caption: CUDA12.6の例

 pip install torch --index-url https://download.pytorch.org/whl/cu126
