unit SXlib;

//Simplified X handling routine

interface
{$INCLUDE DelphiXcfg.inc}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFDEF QDA_SUPPORT}QDArc,{$ENDIF}
  DXDraws, DirectX, D3DUtils, DXClass;

(* SXF形式について

    name   | ofs          | length                  | comment
----------------------------------------------------------------------------------------------------
 Signature |            0 |                      16 | 'Simplified_X01  '
 nVextices |           16 |                       2 | number of vertices
 nIndices  |           18 |                       2 | number of indices for vertices
 dwFVF     |           20 |                       4 | flags for flexible vertex format
 VertexSize|           24 |                       4 | required bytes per vertex

 Vertices  |          256 |  VertexSize * nVertices | vertices
 Indices   | 256+Vertices |           2 * nIndices  | indices for vertices

 *)

(* SX形式について(古い)

    name   | ofs          | length         | comment
----------------------------------------------------------------------------
 Signature |            0 |             16 | 'Simplified_X00  '
 nVextices |           16 |              2 | number of vertices
 nIndices  |           18 |              2 | number of indices for vertices

 Vertices  |          256 | 40 * nVertices | vertices(TSXVertex)
 Indices   | 256+Vertices |  2 * nIndices  | indices for vertices

*)

const

//SXファイル識別子
//SX file identifier
  SX_SIGNATURE: string[16] = 'Simplified_X00  '; //SXFlexible
  SXF_SIGNATURE: string[16] = 'Simplified_X01  '; //古いSX

//メッシュを描画するときに一度にDirect3Dに流し込む頂点の最大数(必ず3の倍数)
//One at a time when drawing the flow into the maximum number of vertices Direct3D mesh (must be a multiple of 3)
  DIV_VERTICES: Word = $FFFF;



//TSXVertex用、FVFフラグ
  FVF_SXVERTEX: DWord = (D3DFVF_VERTEX or D3DFVF_DIFFUSE or D3DFVF_SPECULAR);

//TSXVertexMT用
  FVF_SXVERTEXMT: DWord = (D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_DIFFUSE or D3DFVF_SPECULAR or D3DFVF_TEX2);

type
  TSXMesh = class;
  TSXFrame = class;
  TSXFrameList = class;
  TSXScene = class;                                                        
  TSXRenderingQueue = class;

//SX形式のための頂点データ
//Vertex data for the SX-style
  TSXVertex = packed record

    case Integer of
      0: (
        x, y, z: Single; //頂点
        nx, ny, nz: Single; //法線
        diffuse: TD3DCOLOR; //ディフューズ
        specular: TD3DCOLOR; //スペキュラ
        tu, tv: Single; //テクスチャ座標 ** Texture coordinates
        );
      1: (
        pos: TD3DVector;
        normal: TD3DVector;
        );
  end;

  PSXVertex = ^TSXVertex;

  TSXVertexArray = array[0..$FFFFFF] of TSXVertex;
  PSXVertexArray = ^TSXVertexArray;

//マルチテクスチャ対応SXVertex
//SXVertex multi-texture support
  TSXVertexMT = packed record
    case Integer of
      0: (
        x, y, z: Single; //頂点
        nx, ny, nz: Single; //法線
        diffuse: TD3DCOLOR; //ディフューズ
        specular: TD3DCOLOR; //スペキュラ
        tu0, tv0: Single; //テクスチャ座標
        tu1, tv1: Single; //テクスチャ座標(2)
        );
      1: (
        pos: TD3DVector;
        normal: TD3DVector;
        );
  end;

  PSXVertexMT = ^TSXVertexMT;

  TSXVertexArrayMT = array[0..$FFFFFF] of TSXVertexMT;
  PSXVertexArrayMT = ^TSXVertexArrayMT;

//ビルボードのための頂点情報
//Billboard top information for
  TSXVertexBB = record
    case Integer of
      0: (
        //視点からの距離1の時の、中心からの相対座標
        //At a distance from the viewpoint of the relative coordinate from the center
        dx, dy: Single;
        color: TD3DCOLOR; //色
        tu, tv: Single; //テクスチャ座標
        );
      1: (
        size: TSngPoint;
        );
  end;

//イベントハンドラ
//Event handler
  TSXRenderMeshEvent = procedure(Sender: TSXFrame) of object;

//ブレンドモード
//Blend
//  TSXBlendMode = (
//    sxbDefault, //普通、透けない
//    sxbAdd, //加算合成
//    sxbAlpha, //半透明
//    sxbSub //減算合成
//    );

//可視属性
//Visible attribute
  TSXVisibility = (
    sxvShow, //見える
    sxvHide, //隠れる。子フレームも含めて
    sxvHideMyself //隠れる。子フレームは隠れない。
    );

//クラス群
//Classes

//メッシュ用クラス
//The Mesh Class
  TSXMesh = class
  private
    procedure SetVertexSize(const Value: DWord);
  protected
    FOwner: TDXDraw; //色々お世話になるDDDDオブジェクト
    FVBuf: IDirect3DVertexBuffer7; //VertexBuffer
    FIndexCount: Word; //頂点インデクスの数
    FVertexCount: Word; //頂点の数
    FFaceCount: Word; //面の数、常に頂点数/3
    FVertexSize: DWord; //１個の頂点あたりのサイズ
    FVFFlags: DWord; //描画させるときのフラグ
    VertexKeepBuf: Pointer; //頂点の配列を入れる。Keep用のバッファとして使う
    FIndices: array of Word; //頂点インデクス
    FLocked: Boolean; //ロック中？
    FPVertex: Pointer; //頂点バッファへのポインタ
    FRecovery: Boolean; //リカバリ中？
    function GetIndex(idx: Word): Word;
    function GetVertex(idx: Word): Pointer;
    procedure SetIndex(idx: Word; const Value: Word);
    procedure SetVertex(idx: Word; const Value: Pointer);
  public
    constructor Create(AOwner: TDXDraw);
    destructor Destroy; override;
    procedure KeepVB; //画面が初期化される時の事を考えて、現在のVBの状態を保持
    procedure RecoverVB; //保持したVBを復元
    property VertexBuffer: IDirect3DVertexBuffer7 read FVBuf; //VertexBuffer
    property IndexCount: Word read FIndexCount; //頂点インデクスの数
    property VertexCount: Word read FVertexCount; //頂点の数
    property FaceCount: Word read FFaceCount; //面の数(頂点の数 / 3
    property Vertex[idx: Word]: Pointer read GetVertex write SetVertex; //頂点への参照
    property Index[idx: Word]: Word read GetIndex write SetIndex; //頂点インデクス
    property FVF: DWord read FVFFlags write FVFFlags; //FlexibleVertexFormatに関するフラグ
    property VertexSize: DWord read FVertexSize write SetVertexSize;
    procedure Draw(dwFlags: DWord); //DrawIndexedPrimitiveVBで全部描画
    procedure DrawPartial(start: Word; count: Word; dwFlags: DWord); //DrawIndexedPrimitiveVBで部分描画
    procedure LoadFromStream(s: TStream);
    procedure LoadFromFile(fileName: string);
    {$IFDEF QDA_SUPPORT}
    procedure LoadFromQDA(QDAName, QDAID: string);
    {$ENDIF}
    function Lock: Pointer;
    procedure Unlock;
    procedure SetSize(newVertexCount, newIndexCount: Word); //バッファの大きさを再設定する、中身は消える
    procedure Optimize;
  end;

{
TSXMesh = class(TSXGenMesh)
  private
    function GetVertex(idx: Word): TSXVertex;  override;
    procedure SetVertex(idx: Word; const Value: TSXVertex); override;
  public

    property Vertex[idx:Word]:TSXVertex read GetVertex write SetVertex; //頂点
    function  Lock:PSXVertexArray;
end;
}

//フレーム
//The Frame
  TSXFrame = class
  private
    FMatrix: TD3DMATRIX; //変換行列(自分の座標系→親座標系)
    FMeshMatrix: TD3DMATRIX; //メッシュ描画時の変換行列…メッシュ座標→自分座標

    FAncestors: TSXFrameList; //祖先フレーム達
    FChildren: TSXFrameList; //子フレーム達
    FParent: TSXFrame; //親フレーム(Ancestors[Ancestors.Count-1]と同)
    FVisibility: TSXVisibility; //可視属性
    FBindRenderState: Boolean; //自分の子孫のレンダリングステートを、強制的に自分のにする
    FBindTexture: Boolean; //自分の子孫のテクスチャを、強制的に自分のにする
    FBindMaterial: Boolean; //自分の子孫のマテリアルを、強制的に自分のにする

    RenderedMatrix: TD3DMATRIX; //最後にレンダリングされたときのワールド行列(ビルボードの描画に使用)
    BBAttached: Boolean; //ビルボードがくっついてる？

    function GetWorldMatrix: TD3DMATRIX;
    procedure SetParent(const Value: TSXFrame);

  public

    //中身
    Texture: TDirect3DTexture2; //メッシュに貼り付けるテクスチャ
    Mesh: TSXMesh; //書き込むメッシュ
    Material: TD3DMATERIAL7; //マテリアル

    //レンダリングステートの制御
    Lighting: Boolean; //True:ライティングをする, False:頂点の色をそのまま使う
    Specular: Boolean; //スペキュラハイライトをつける
    BlendMode: TRenderType; //描画時のブレンドモード

    //イベントハンドラ
    OnRenderMesh: TSXRenderMeshEvent; //メッシュをこれから書きますですイベント

    //いろいろ
    Tag: DWord; //整数値、なんにでも使って
    RenderAttr: Integer; //整数値、OnRenderMeshで、マテリアル番号代わりにどうぞ

    //コンストラクタ・デストラクタ
    constructor Create(parentFrame: TSXFrame);
    destructor Destroy; override;

    //親子関係
    property Ancestors: TSXFrameList read FAncestors;
    property Children: TSXFrameList read FChildren;
    property Parent: TSXFrame read FParent write SetParent;
    property BindRenderState: Boolean read FBindRenderState write FBindRenderState;
    property BindTexture: Boolean read FBindTexture write FBindTexture;
    property BindMaterial: Boolean read FBindMaterial write FBindMaterial;

    //可視属性
    property Visibility: TSXVisibility read FVisibility write FVisibility;

    //座標変換関係
    property Matrix: TD3DMATRIX read FMatrix write FMatrix;
    property WorldMatrix: TD3DMATRIX read GetWorldMatrix; //自分座標→ワールド座標の変換行列
    property MeshMatrix: TD3DMATRIX read FMeshMatrix write FMeshMatrix; //メッシュ描画時の変換行列…メッシュ座標→自分座標

    procedure SetTransform(ref: TSXFrame; const mat: TD3DMATRIX);
    function GetTransform(ref: TSXFrame): TD3DMATRIX;

    function LocalToWorld(vec: TD3DVector): TD3DVector; //フレーム内での座標を、ワールド座標に変換する
    function WorldToLocal(vec: TD3DVector): TD3DVector; //ワールド座標内の座標をフレーム内の座標に変換する

    //位置
    procedure SetTranslation(ref: TSXFrame; const pos: TD3Dvector);
    function GetTranslation(ref: TSXFrame): TD3DVector;

    //姿勢
    //…軸ベクトルで設定・取得
    procedure SetOrientation(ref: TSXFrame; const vecZ: TD3DVector; const vecY: TD3DVector);
    procedure GetOrientation(ref: TSXFrame; var vecZ: TD3DVector; var vecY: TD3DVector);
    //…マトリクスを与えて姿勢だけ設定
    procedure SetOrientationMatrix(ref: TSXFrame; const mat: TD3DMATRIX);

    //お便利
    //…Z軸をtargetフレーム内の座標posを向ける。Y軸はworldフレーム内のY軸に向け。Y軸の傾きをbank度とする
    procedure LookAt(target: TSXFrame; const pos: TD3DVector; world: TSXFrame; const bank: Integer);
    function ViewMatrix: TD3DMatrix; //このフレームをカメラにした場合のビュー行列を生成
  end;

//フレームのリスト
//List of frames
  TSXFrameList = class(TList)
  private
    function GetFrame(idx: Integer): TSXFrame;
    procedure SetFrame(idx: Integer; const Value: TSXFrame);
  public
    property Frames[idx: Integer]: TSXFrame read GetFrame write SetFrame; default;
    constructor Create;
    destructor Destroy; override;
    procedure Assign(source: TSXFrameList);
  end;

//シーン全体
  TSXScene = class
  private
    FCamera: TSXFrame;
    FOwner: TDXDraw;

    FProjectionMatrix: TD3DMATRIX;
    FVP: TD3DVIEWPORT7;

    OpaqueQueue: TSXRenderingQueue; //不透明体用のキュー
    AlphaQueue: TSXRenderingQueue; //半透明透明体用のキュー
    AddQueue: TSXRenderingQueue; //加算半透明体用のキュー
    SubQueue: TSXRenderingQueue; //減算半透明体用のキュー

    //ProcessVertices用
    //MeshProcessor:TSXMesh;          //Lightingをしないとき・環境マップする時用
    //MeshProcessorMT:TSXMesh;        //同上、ただしマルチテクスチャ(2ステージ)版
  public
    constructor Create(DDCompo: TDXDraw);
    destructor Destroy; override;

    property CameraFrame: TSXFrame read FCamera write FCamera; //視点を置くフレーム

    procedure Render(rootFrame: TSXFrame); //rootFrame以下を描画
    procedure Clear(dwFlags: DWord; color: DWORD; z: Single; stencil: DWord); //バックバッファのクリア

    procedure SetProjection(fov, aspect, nearZ, farZ: Single); //透視変換の設定
    procedure SetViewPort(left, top, right, bottom: DWord); //ビューポート

    procedure Recover; //ビューポートなどの状態をリストア

    procedure PushBillboard(blendMode: TRenderType; ref: TSXFrame; pos: TD3DVector; points: array of TSXVertexBB; tex: TDirect3DTexture2);
    function SphereVisibility(ref: TSXFrame; pos: TD3DVector; radius: Single; depth: Single): Boolean; //refフレーム内にある、中心pos、半径radiusの球は見えるか、但し、距離がdepth以上なら見えないものとする
  end;

//ライト
  TSXLight = class
  private
    FOwner: TDXDraw;
    FIndex: DWord; //SetLightに渡す、インデクス
    FEnabled: Boolean;
    FUpdate: Boolean; //パラメータの変更を、即反映
    procedure SetEnabled(const Value: Boolean);
  public
    Params: TD3DLIGHT7;

    constructor Create(DDCompo: TDXDraw; index: DWord);
    destructor Destroy; override;

    procedure BeginUpdate; //Paramsの内容を、Direct3Dに伝えなくする
    procedure EndUpdate; //Paramsの内容を、Direct3Dに伝えなくした状態を解除

    property Enabled: Boolean read FEnabled write SetEnabled;

    //お便利ルーチン
    procedure SetupDiffuse(_R, _G, _B: Single);
    procedure SetupSpecular(_R, _G, _B: Single);
    procedure SetupAmbient(_R, _G, _B: Single);

    procedure SetupColors(difR, difG, difB, specR, specG, specB, ambR, ambG, ambB: Single);
    procedure SetupRanges(range, att0, att1, att2: Single);

    procedure SetupDirectional(dir: TD3DVector);
    procedure SetupPoint(pos: TD3DVector);
    procedure SetupSpot(pos, dir: TD3DVector; theta, phi, falloff: Single);

    procedure FitFrame(target: TSXFrame); //フレームの位置・向きにセットする
  end;

//複数のライトを管理するオブジェクト
  TSXLightGroup = class(TList)
  private
    FOwner: TDXDraw;
    FCapacity: DWord; //管理するライトの数
    FLights: array of TSXLight;
    //FSpecularPower:Single;                                   //スペキュラ強度
    function GetLights(idx: DWord): TSXLight;
    function GetUnusedLight: TSXLight;
//    procedure SetSpecularPower(const Value: Single);
  public
    constructor Create(DDCompo: TDXDraw; capacity: DWord);
    destructor Destroy; override;

    property Lights[idx: DWord]: TSXLight read GetLights; default;
    property UnusedLight: TSXLight read GetUnusedLight; //Enabledになってない、最初のライトを返す
    //property SpecularPower:Single read FSpecularPower write SetSpecularPower;

    procedure EnableAll; //全部点ける
    procedure DisableAll; //全部消す

    procedure Recover; //解像度を変えた後などのリカバリ
  end;

  TSXMaterial = class
  private
    FOwner: TDXDraw;
    FUpdate: Boolean;
  public
    Params: TD3DMATERIAL7;
    constructor Create(DDCompo: TDXDraw);

    procedure BeginUpdate; //Paramsの内容を、Direct3Dに伝えなくする
    procedure EndUpdate; //Paramsの内容を、Direct3Dに伝えなくした状態を解除

    procedure SetupDiffuse(_R, _G, _B: Single);
    procedure SetupSpecular(_R, _G, _B: Single);
    procedure SetupAmbient(_R, _G, _B: Single);
    procedure SetupEmissive(_R, _G, _B: Single);
    procedure SetupSpecularPower(pow: Single);

    procedure SetupColors(difR, difG, difB, specR, specG, specB, ambR, ambG, ambB, emsR, emsG, emsB, pow: Single);
  end;

//メッシュ描画キューに入れる情報
  TSXMeshInfo = record
    frame: TSXFrame; //そのメッシュを描こうとしたフレームはどれ？
    mesh: TSXMesh; //メッシュ
    mat: TD3DMatrix; //変換行列
    tex: TDirect3DTexture2; //テクスチャ
    mtrl: TD3DMATERIAL7; //マテリアル
    lighting: Boolean; //光源計算する/しない
    OnRender: TSXRenderMeshEvent;
  end;

//ビルボード描画キューに入れる情報
  TSXBillboardInfo = record
    ref: TSXFrame; //基準フレーム
    pos: TD3DVector; //基準フレーム内での位置
    tex: TDirect3DTexture2; //テクスチャ
    pts: array[0..3] of TSXVertexBB; //頂点データ
  end;

//レンダリングの順序を保つためのバッファ、透明体かそうでないかで順序を変える。
//Render order to maintain the buffer, or not change the order in a transparent body.
  TSXRenderingQueue = class
  private
    FOwner: TDXDraw; //色々お世話になるDDDDオブジェクト
    Scene: TSXScene; //この

    MeshQueue: array of TSXMeshInfo;
    BillboardQueue: array of TSXBillboardInfo;

    FMeshCapacity: Integer; //メッシュを情報蓄える容量
    FBillboardCapacity: Integer;

    FMeshCount: Integer; //キューに入ってる数
    FBillboardCount: Integer;

    procedure SetBillBoardCapacity(const Value: Integer);
    procedure SetMeshCapacity(const Value: Integer); //ビルボードについての情報を蓄える容量
  public
    constructor Create(AOwner: TDXDraw; _Scene: TSXScene);
    destructor Destroy; override;
    procedure PushMesh(mesh: TSXMesh; frame: TSXFrame; mat: TD3DMatrix; tex: TDirect3DTexture2; mtrl: TD3DMATERIAL7; event: TSXRenderMeshEvent); //メッシュ
    procedure PushBillboard(ref: TSXFrame; pos: TD3DVector; tex: TDirect3DTexture2; pts: array of TSXVertexBB); //ビルボード
    procedure Render(viewMat: TD3DMATRIX; viewParam: TD3DVIEWPORT7); //レンダリング
    procedure Flush; //レンダリングせず、バッファの中を空に     **Without rendering the buffer to empty

    property MeshCapacity: Integer read FMeshCapacity write SetMeshCapacity;
    property BillboardCapacity: Integer read FBillboardCapacity write SetBillBoardCapacity;
    property MeshCount: Integer read FMeshCount;
    property BillboardCount: Integer read FBillboardCount;
  end;

  {Renderer of the primitive}

  TSXPrimitiveRec = packed record
    Texture: TDirect3DTexture2; //テクスチャ
    Bound: array[0..3] of TD3DTLVertex; //四角形
    ZOrder: Integer; //Zオーダ
    BlendMode: TRenderType; //ブレンドモード
  end;
  PPrimitive = ^TSXPrimitiveRec;

  TSXTextureCoordRec = packed record
    Texture: TDirect3DTexture2;
    Top, Left, Bottom, Right: Single; //テクスチャ座標
  end;
  PTextureCoord = ^TSXTextureCoordRec;

  TSingleRect = packed record
    Left, Top, Right, Bottom: Single;
  end;

  TSXPrimitiveRenderer = class
  private
    FDXDraw: TDXDraw;
    FZMax: Integer; //Zオーダの最大値
    FMaxPrimitives: Integer; //格納できるTLVの最大値

    ZSortBuf: ^Integer; //Zソート用バッファ
    ZSortCount: ^Integer; //Zソート用カウンタ
    PrimBuf: PPrimitive; //プリミティブ入れ
    PrimCount: Integer; //現在PrimBufに入ってるプリミティブの数
    Patterns: PTextureCoord; //テクスチャパターン
    FNPrims: Integer; //最後にUpdateメソッドを発行した際の、プリミティブの数
    FColorKey: Boolean; //カラーキーによる抜き色を行う？
    procedure setZMax(v: Integer);
  public
    constructor Create(DDCompo: TDXDraw; PrimitiveCount: Integer; PatternCount: Integer);
    destructor Destroy; override;
    property ZMax: Integer read FZMax write setZMax;

    procedure SetPattern(idx: Integer; Tex: TDirect3DTexture2; Coord: TRect); //パターンとしてTexのCoordで示される範囲を登録

    procedure Push(Tex: TDirect3DTexture2; p1, p2, p3, p4: TD3DTLVertex; Z: Integer; blend: TRenderType); //TLVertexで四角形を入れる
    procedure Push2D(Tex: TDirect3DTexture2; p1, p2, p3, p4: TD2DVector; Z: Integer; blend: TRenderType; col: DWord); //2D的な四角形

    procedure PushPattern(iPat: Integer; p1, p2, p3, p4: TD3DHVector; Z: Integer; blend: TRenderType; col: DWord); //パターンをプッシュ(3次元)
    procedure PushPattern2D(iPat: Integer; p1, p2, p3, p4: TD2DVector; Z: Integer; blend: TRenderType; col: DWord); //パターンをプッシュする
    procedure PushPatternRect(iPat: Integer; rect: TSingleRect; Z: Integer; blend: TRenderType; col: DWord); //パターンをプッシュする(矩形)

    procedure BeginRender; //Z値にしたがってソート
    procedure RenderOneLayer(Z: Integer); //単一のZ値を持つ集合だけ描画
    procedure EndRender; //スタックを空に
    procedure Render; //全部描画(BeginRender～RenderOneLayer～EndRender)

    property nPrims: Integer read FNPrims;
    property ColorKey: Boolean read FColorKey write FColorKey;

    class function SingleRect(x1, y1, x2, y2: Single): TSingleRect;
  end;

//SXVertex作成
function SXVertex(x, y, z, nx, ny, nz: Single; dif, spec: TD3DCOLOR; tu, tv: Single): TSXVertex;

//SXVertexBB作成
function SXVertexBB(dx, dy: Single; col: TD3DCOLOR; tu, tv: Single): TSXVertexBB;

//マテリアル設定の便宜を図る関数
//Convenience function for setting material
function MakeMaterial(difR, difG, difB, specR, specG, specB, ambR, ambG, ambB, emsR, emsG, emsB, pow: Single): TD3DMATERIAL7;

implementation

type
  TSXTLVertexMT = packed record
    case Integer of
      0: (
        x, y, z, rhw: Single; //頂点
        diffuse: TD3DCOLOR; //ディフューズ
        specular: TD3DCOLOR; //スペキュラ
        tu0, tv0: Single; //テクスチャ座標
        tu1, tv1: Single; //テクスチャ座標2
        );
      1: (
        pos: TD3DVector;
        );
      2: (
        hgPos: TD3DHVector;
        );
  end;

const
  FVF_SXTLVertexMT: DWord = (D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_SPECULAR or D3DFVF_TEX2);

{ Helper functions }

function SXVertex(x, y, z, nx, ny, nz: Single; dif, spec: TD3DCOLOR; tu, tv: Single): TSXVertex;
begin
  result.x := x;
  result.y := y;
  result.z := z;
  result.nx := nx;
  result.ny := ny;
  result.nz := nz;

  result.diffuse := dif;
  result.specular := spec;

  result.tu := tu;
  result.tv := tv;

end;

function SXVertexBB(dx, dy: Single; col: TD3DCOLOR; tu, tv: Single): TSXVertexBB;
begin
  result.dx := dx;
  result.dy := dy;

  result.color := col;

  result.tu := tu;
  result.tv := tv;
end;

{ TSXMesh }

//コンストラクタ
//Constructor

constructor TSXMesh.Create(AOwner: TDXDraw);
begin
  inherited Create;

  FOwner := AOwner;
  FVBuf := nil;
  SetLength(FIndices, 0);
  FIndexCount := 0;
  FFaceCount := 0;
  FVertexCount := 0;
  VertexKeepBuf := nil;

  FVertexSize := sizeof(TSXVertex);
  FVFFlags := FVF_SXVERTEX;

  FLocked := False;
  FRecovery := False;

end;

//デストラクタ
//Destructor

destructor TSXMesh.Destroy;
begin
  if FVBuf <> nil then
    FVBuf := nil; //._Release;

  if VertexKeepBuf <> nil then
    FreeMem(VertexKeepBuf);

  FIndices := nil;

  inherited;
end;

//現在のVertexBufferの状態を保持
//Currently holds the state of VertexBuffer

procedure TSXMesh.KeepVB;
begin
  if FVBuf <> nil then
  begin
    //バッファサイズの変更
    //Resizing of the buffer
    if VertexKeepBuf <> nil then
      FreeMem(VertexKeepBuf);
    VertexKeepBuf := AllocMem(VertexSize * FVertexCount);

    Self.Lock;
    Move(FPVertex^, VertexKeepBuf^, VertexSize * FVertexCount);
    Self.Unlock;
  end;
end;

//保存したVertexBufferの状態を復元
//Restore the state saved VertexBuffer


procedure TSXMesh.RecoverVB;
begin

  if FVBuf <> nil then
  begin
    //リカバリ期間・開始
    //Recovery period begins
    FRecovery := True;
    FVBuf := nil;

    SetSize(FVertexCount, FIndexCount);

    Self.Lock;
    Move(VertexKeepBuf^, FPVertex^, VertexSize * FVertexCount);
    Self.Unlock;

    FreeMem(VertexKeepBuf);
    VertexKeepBuf := nil;
    FRecovery := False;
    //リカバリ期間・終了
    //Recovery period ends
  end;
end;

//DPで描画
//Simple DP draw

procedure TSXMesh.Draw(dwFlags: DWord);
var
  ofs: Word;
  nIs: Word;
begin
  ofs := 0;
  while ofs < FIndexCount do
  begin

    nIs := FIndexCount - ofs;
    if nIs > DIV_VERTICES then
      nIs := DIV_VERTICES;

    FOwner.D3DDevice7.DrawIndexedPrimitiveVB(
      D3DPT_TRIANGLELIST, FVBuf, 0, FVertexCount, FIndices[ofs], nIs, dwFlags);

    Inc(ofs, nIs);
  end;
end;

//DPで描画
//Draw DP strem of primitives

procedure TSXMesh.DrawPartial(start: Word; count: Word; dwFlags: DWord);
begin
  FOwner.D3DDevice7.DrawIndexedPrimitiveVB(
    D3DPT_TRIANGLELIST, FVBuf, 0, FVertexCount, FIndices[start], count, dwFlags);
end;

//インデクス操作
//Check index

function TSXMesh.GetIndex(idx: Word): Word;
begin
  if idx >= FIndexCount then
  begin
    //DDDD_PutDebugMessage('SXLib: 範囲外の頂点インデクスを参照しようとしました');
    result := 0;
    exit;
  end;

  result := FIndices[idx];
end;

procedure TSXMesh.SetIndex(idx: Word; const Value: Word);
begin
  if idx >= FIndexCount then
  begin
    //DDDD_PutDebugMessage('SXLib: 範囲外の頂点インデクスを設定しようとしました');
    exit;
  end;

  FIndices[idx] := Value;
end;

//頂点操作
//Operation on Vertex

function TSXMesh.GetVertex(idx: Word): Pointer;
var
  pV: Pointer;
  ofs: DWord;
  lpdwSize: Cardinal;
begin
  //範囲チェック
  //check range
  if idx >= FVertexCount then
  begin
    //DDDD_PutDebugMessage('SXLib: 範囲外の頂点を参照しようとしました');
    result := nil;
    exit;
  end;

  //ロックされていないなら、ロック。ロックされてるなら、前に得たポインタをゲット
  //when is unlocked, then lock there
  if not FLocked then
  begin
    if FVBuf.Lock(DDLOCK_READONLY or DDLOCK_WAIT, pV, lpdwSize) <> DD_OK then
    begin
      //DDDD_PutDebugMessage('SXLib: VertexBufferがロックできません');
      Halt;
    end;
  end
  else
    pV := FPVertex;

  //返り値に格納
  //calc place of vertices
  ofs := idx * VertexSize;
  asm
    mov   eax,ofs;
    add   pV,eax;
  end;
  result := pV;

  //アンロック
  //unlock
  if not FLocked then
  begin
    if FVBuf.Unlock <> DD_OK then
    begin
      //DDDD_PutDebugMessage('SXLib: VertexBufferがアンロックできません');
      Halt;
    end;
  end;

end;

procedure TSXMesh.SetVertex(idx: Word; const Value: Pointer);
var
  ofs: DWord;
  pV: ^TSXVertex;
  lpdwSize: Cardinal;
begin
  //範囲チェック
  //check range
  if idx >= FVertexCount then
  begin
    //DDDD_PutDebugMessage('SXLib: 範囲外の頂点を変更しようとしました');
    exit;
  end;

  //ロックされていないなら、ロック。ロックされてるなら、前に得たポインタをゲット
  //Test when unlocked, and after test lock
  if not FLocked then
  begin
    if FVBuf.Lock(DDLOCK_WRITEONLY or DDLOCK_WAIT, Pointer(pV), lpdwSize) <> DD_OK then
    begin
      //DDDD_PutDebugMessage('SXLib: VertexBufferがロックできません');
      Halt;
    end;
  end
  else
    pV := FPVertex;

  //格納するっす
  //physic size of vertices stream
  ofs := idx * VertexSize;
  asm
    mov   eax,ofs;
    add   pV,eax;
  end;
  Move(Value^, pV^, VertexSize);

  //Unlock
  if not FLocked then
  begin
    if FVBuf.Unlock <> DD_OK then
    begin
      //DDDD_PutDebugMessage('SXLib: VertexBufferがアンロックできません');
      Halt;
    end;
  end;
end;

//1Vertexあたりのサイズを変更
//Set size for all Vertexes
procedure TSXMesh.SetVertexSize(const Value: DWord);
begin
  FVertexSize := Value;
  SetSize(FVertexCount, FIndexCount);
end;

//ストリームから読み込み
//Reading from strem

procedure TSXMesh.LoadFromStream(s: TStream);
var
  sign: array[0..16] of AnsiChar;
  nVertices, nIndices: Word;
  StartPos: Integer;
begin

  StartPos := s.Position;

  //シグネチャの確認
  //Check of the signature
  sign[16] := Chr(0);
  s.ReadBuffer(sign, 16);

  if StrPas(sign) = SX_SIGNATURE then
  begin
    //SX形式
    FVertexSize := Sizeof(TSXVertex);
    FVFFlags := FVF_SXVERTEX;
    //頂点数・頂点インデクス数の設定
    //Setting the number of vertices of vertex indices
    s.ReadBuffer(nVertices, Sizeof(Word));
    s.ReadBuffer(nIndices, Sizeof(Word));
  end
  else
    if StrPas(sign) = SXF_SIGNATURE then
    begin
      //頂点数・頂点インデクス数の設定
      //Setting the number of vertices of vertex indices
      s.ReadBuffer(nVertices, Sizeof(Word));
      s.ReadBuffer(nIndices, Sizeof(Word));
      //SXFlexible format
      s.ReadBuffer(FVFFlags, Sizeof(DWord));
      s.ReadBuffer(FVertexSize, Sizeof(DWord));
    end
    else
    begin
      //DDDD_PutDebugMessage('SXLib: 不正なSXファイルです');
      Halt;
    end;

  SetSize(nVertices, nIndices);

  //ヘッダのスキップ
  //Skip header
  s.Position := StartPos + 256;

  try
    //頂点のロード
    //Peak load
    Lock;
    s.ReadBuffer(FPVertex^, VertexSize * nVertices);
    Unlock;

    //頂点インデクスのロード
    //Load indexes
    s.ReadBuffer(FIndices[0], Sizeof(Word) * nIndices);
  except
    //DDDD_PutDebugMessage('SXLib: ストリームからの読み込み中にエラーが発生しました');
    Halt;
  end;

end;

//ファイルから読み込み
//Load from file by name

procedure TSXMesh.LoadFromFile(fileName: string);
var
  fs: TFileStream;
begin
  fs := nil;

  try
    fs := TFileStream.Create(filename, fmOpenRead);
  except
    //DDDD_PutDebugMessage('SXLib: ' + filename + ' が、開けません');
    Halt;
  end;

  LoadFromStream(fs);
  fs.Free;
end;

{$IFDEF QDA_SUPPORT}
//QDAから読み込み
procedure TSXMesh.LoadFromQDA(QDAName, QDAID: string);
var
  ms: TMemoryStream;
begin
  ms := nil;

  try
    ms := ExtractFromQDAFile(QDAName, QDAID);
  except
    //DDDD_PutDebugMessage('SXLib: ' + QDAname + ' 内の、' + QDAID + 'が抽出できません');
    Halt;
  end;

  LoadFromStream(ms);
  ms.Free;
end;
{$ENDIF}

//VertexBuffer Lock

function TSXMesh.Lock: Pointer;
var lpdwSize: Cardinal;
begin
  if FVBuf.Lock(DDLOCK_WAIT, Pointer(FPVertex), lpdwSize) <> DD_OK then
  begin
    //DDDD_PutDebugMessage('SXLib: VertexBufferがロックできません');
    Halt;
  end;

  result := FPVertex;
  FLocked := True;
end;

//VertexBuffer unlock

procedure TSXMesh.Unlock;
begin
  if FVBuf.Unlock <> DD_OK then
  begin
    //DDDD_PutDebugMessage('SXLib: VertexBufferがアンロックできません');
    Halt;
  end;

  FLocked := False;
end;

//頂点配列とインデクス配列のサイズを再設定
//Reconfigure the size of the array and vertex array indices

procedure TSXMesh.SetSize(newVertexCount, newIndexCount: Word);
var
  vbdesc: TD3DVERTEXBUFFERDESC;
begin
  FVertexCount := newVertexCount;
  FIndexCount := newIndexCount;
  FFaceCount := newIndexCount div 3;

  //まず、既存のVertexBufferの解放
  //When exist VertexBuffer, release it
  if FVBuf <> nil then
    FVBuf := nil; //.Release;

  //VertexBufferの生成
  //Generate VertexBuffer
  ZeroMemory(@vbdesc, Sizeof(vbdesc));
  with vbdesc do
  begin
    dwSize := Sizeof(vbdesc);
    {$IFNDEF D3D_deprecated}
    if not (dtTnLHAL in FOwner.D3DDeviceTypeSet) then
      dwCaps := D3DVBCAPS_SYSTEMMEMORY
    else
    {$ENDIF}
      dwCaps := 0;

    dwFVF := FVFFlags;
    dwNumVertices := newVertexCount;
  end;
  FOwner.D3D7.CreateVertexBuffer(vbdesc, FVBuf, 0);

  //頂点インデクス配列の設定
  //Vertex set of the array index

  if not FRecovery then
    SetLength(FIndices, newIndexCount);

end;

//最適かするっ。ロックとかはできなくなるよ
//Optimize, cannot be locked
procedure TSXMesh.Optimize;
begin
  FVBuf.Optimize(FOwner.D3DDevice7, 0);
end;

{ TSXFrame }

constructor TSXFrame.Create(parentFrame: TSXFrame);
begin
  inherited Create;

  //親子関係の初期化
  //Initialize parent-child relationship
  FAncestors := TSXFrameList.Create;
  if ParentFrame <> nil then
  begin
    //Ancestral copy of the list
    FAncestors.Assign(parentFrame.Ancestors); //先祖リストのコピー
    //Fathers at the end of the list, put the parent
    FAncestors.Add(parentFrame); //先祖リストの末尾に、親を入れる
    //Parents put their children to the list
    ParentFrame.Children.Add(Self); //親の子リストに自分をつける
  end;

  FChildren := TSXFrameList.Create;
  FParent := parentFrame;

  FBindMaterial := False;
  FBindRenderState := False;
  FBindTexture := False;


  //変数とかの初期化
  //Variable Or First Initialization

  FMatrix := D3DUtil_SetIdentityMatrix;
  FMeshMatrix := D3DUtil_SetIdentityMatrix;

  BlendMode := rtDraw;
  Material := MakeMaterial(1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0);

  Visibility := sxvShow;
  Lighting := True;
  Specular := True;


  OnRenderMesh := nil;
  Mesh := nil;
  Texture := nil;

end;

destructor TSXFrame.Destroy;
begin
  inherited;

  while Children.Count > 0 do
  begin //This child frame is recursively Freed
    Children[0].Free; //これで、再帰的に子フレームがFreeされる
  end;

  //リストオブジェクトの解放
  //Object free list

  FChildren.Free;
  FAncestors.Free;

  //親のリストから自分をはずす
  //Remove yourself from the list of parents

  if Parent <> nil then
    Parent.Children.Delete(Parent.Children.IndexOf(Self));

end;

//自分の座標→ワールド座標　のための変換行列を得る
//To obtain the world coordinate transformation matrix → coordinate their

function TSXFrame.GetWorldMatrix: TD3DMATRIX;
var
  mat: TD3DMATRIX;
  i: Integer;
begin

  mat := FMatrix;

  //祖先のマトリクスを 親→祖父… の順に乗じていく。
  //Ancestors[0] はNilであり、途中にNilは入らないという前提の下に計算
  // Parent → grandfather ... we multiply the matrix of the ancestral order.
  // Ancestors [0] is not Nil, Nil way under the assumption that the fit is calculated

  for i := Ancestors.Count - 1 downto 1 do
  begin
    {$IFDEF USE_S_MATHPACK}
    mat := NowCompositeMatrix(mat, Ancestors[i].FMatrix);
    {$ELSE}
    D3DMath_MatrixMultiply(mat, FMatrix, Ancestors[i].FMatrix)
    {$ENDIF}
  end;

  result := mat;
end;

//…Z軸をtargetフレーム内の座標posを向ける。worldフレームのY軸をupベクトルに指定し、Y軸のZ軸回りの傾きをbank度とする
// Z axis toward the target coordinates in the frame pos. Y-axis of world frame specified in the up vector, Y and Z axis tilt of the axis around which at bank

procedure TSXFrame.LookAt(target: TSXFrame; const pos: TD3DVector; world: TSXFrame; const bank: Integer);
var
  vRel: TD3DVECTOR; //Targetとの相対座標   //Target coordinates to relative
  vecCeil: TD3Dvector; //天井のベクトル  //Vector Ceiling
  vecX, vecY, vecZ: TD3DVECTOR;
  normX: Single; //X軸の長さ(天井とZが平行かどうかのチェック用)
                 //The length of the X-axis (Z and for checking whether the ceiling parallel)
begin

  {
  //targetのposは、自分の座標系でどこなのか
  vRel:=WorldToLocal(target.LocalToWorld(pos));

  //向き = Z軸ベクトル
  vecZ:=NowNormalize(vRel);

  //YZ平面にvRelを射影して、X軸と外積を取って新しいY軸を得る
  vecY:=NowCrossProduct(Vector(0,vecZ.Y,vecZ.Z), Vector(1,0,0));

  vecY:=NowNormalize(vecY);

  SetOrientation(Self, vecZ, vecY);
  }


  //targetのposは、自分の座標系でどこなのか
  //pos of target, or a coordinate system where one

  vRel := WorldToLocal(target.LocalToWorld(pos));

  //向き = Z軸ベクトル
  //Direction = Z axis vector

  {$IFDEF USE_S_MATHPACK}
  vecZ := NowNormalize(vRel);
  {$ELSE}
  vecZ := D3DMath_VecNormalize(vRel);
  {$ENDIF}
  //天井の向き = worldのY軸
  //Ceiling Direction = World of the Y-axis

  {$IFDEF USE_S_MATHPACK}
  vecCeil := NowSub(WorldToLocal(world.LocalToWorld(Vector(0, 1, 0))), WorldToLocal(world.LocalToWorld(Vector(0, 0, 0))));
  vecCeil := NowNormalize(vecCeil);
  {$ELSE}
  vecCeil := D3DMath_Vec3Subtract(WorldToLocal(world.LocalToWorld(MakeD3DVector(0, 1, 0))), WorldToLocal(world.LocalToWorld(MakeD3DVector(0, 0, 0))));
  vecCeil := D3DMath_VecNormalize(vecCeil);
  {$ENDIF}

  //天井とZで外積を取って、Xの向きとする
  //Taking the cross product in the ceiling and Z and the direction of the X

  {$IFDEF USE_S_MATHPACK}
  vecX := NowCrossProduct(vecCeil, vecZ);
  {$ELSE}
  vecX := D3DMath_Vec3Cross(vecCeil, vecZ);
  {$ENDIF}

  //天井とZが平行な場合、右耳の方向をworldのX軸にする
  //And Z is parallel to the ceiling, the direction of the X-axis of the world right ear
  {$IFDEF USE_S_MATHPACK}
  normX := NowLength(vecX);
  {$ELSE}
  normX := D3DMath_Vec3Length(vecX);
  {$ENDIF}
 if normX < 0.0001 then
  {$IFDEF USE_S_MATHPACK}
    vecX := NowSub(WorldToLocal(world.LocalToWorld(Vector(1, 0, 0))), WorldToLocal(world.LocalToWorld(Vector(0, 0, 0))));
  {$ELSE}
    vecX := D3DMath_Vec3Subtract(WorldToLocal(world.LocalToWorld(MakeD3DVector(1, 0, 0))), WorldToLocal(world.LocalToWorld(MakeD3DVector(0, 0, 0))));
  {$ENDIF}

  {$IFDEF USE_S_MATHPACK}
  vecX := NowNormalize(vecX);
  {$ELSE}
  vecX := D3DMath_VecNormalize(vecX);
  {$ENDIF}

  //XとZで外積を取って、Yの向きとする
  //Taking the cross product in X and Z direction and the Y

  {$IFDEF USE_S_MATHPACK}
  vecY := NowNormalize(NowCrossProduct(vecZ, vecX));
  {$ELSE}
  vecY := D3DMath_VecNormalize(D3DMath_Vec3Cross(vecZ, vecX));
  {$ENDIF}

  //以上で姿勢の計算完了～セット
  //Complete set - at least calculate the position

  SetOrientation(Self, vecZ, vecY);

  //バンク
  //Bank
  if bank <> 0 then
  {$IFDEF USE_S_MATHPACK}
    SetTransform(Self, NowRotZMatrix(bank));
  {$ELSE}
  begin
    SetTransform(Self, D3DUtil_SetRotateZMatrix(bank));
  end;  
  {$ENDIF}
end;

//refに対する変換行列の設定

procedure TSXFrame.SetTransform(ref: TSXFrame; const mat: TD3DMATRIX);
begin

  if ref = Self then
  begin
    //自分への変換行列
    {$IFDEF USE_S_MATHPACK}
    FMatrix := NowCompositeMatrix(mat, FMatrix);
    {$ELSE}
    FMatrix := D3DMath_MatrixMultiply(mat, FMatrix)
    {$ENDIF}


  end
  else
    if ref = Parent then
    begin
      //親への変換行列
      //Transformation matrix to the parent
      FMatrix := mat;

    end
    else
    begin

      //自分→ref→ワールド→親
      //Ones to ref to World to Parent
      if Parent <> nil then
      begin
        if ref <> nil then
    {$IFDEF USE_S_MATHPACK}
          FMatrix := NowCompositeMatrix(
            NowCompositeMatrix(mat, ref.WorldMatrix),
            NowInvMatrix(Parent.WorldMatrix)
          )
    {$ELSE}
        begin
          FMatrix := D3DMath_MatrixMultiply(D3DMath_MatrixMultiply(mat, WorldMatrix), D3DMath_MatrixInvert(Parent.WorldMatrix))
        end
    {$ENDIF}
        else
    {$IFDEF USE_S_MATHPACK}
          FMatrix := NowCompositeMatrix(mat, NowInvMatrix(Parent.WorldMatrix));
    {$ELSE}
        begin
          FMatrix := D3DMath_MatrixMultiply(mat, D3DMath_MatrixInvert(Parent.WorldMatrix));
        end
    {$ENDIF}
      end
      else
      begin
        if ref <> nil then
    {$IFDEF USE_S_MATHPACK}
          FMatrix := NowCompositeMatrix(mat, ref.WorldMatrix)
    {$ELSE}
        begin
          FMatrix := D3DMath_MatrixMultiply(mat, ref.WorldMatrix)
        end
    {$ENDIF}
        else
          FMatrix := mat;
      end;
    end;
end;

//refに対する変換行列の取得
//ref to get the transformation matrix

function TSXFrame.GetTransform(ref: TSXFrame): TD3DMATRIX;
begin

  if ref = Self then
  begin
    //自分への変換を得る…単位行列に決まってる。
    //Their conversion to get ... I decided the matrix.

    result := D3DUtil_SetIdentityMatrix;

  end
  else
    if ref = Parent then
    begin

      //親へのオリエンテーションを得る
      //Get to the parent orientation

      result := FMatrix;

    end
    else
    begin

      //自分→ワールド→ref
      //Ones to World to Ref
      if ref <> nil then
    {$IFDEF USE_S_MATHPACK}
        result := NowCompositeMatrix(WorldMatrix, NowInvMatrix(ref.WorldMatrix))
    {$ELSE}
        begin
          Result := D3DMath_MatrixMultiply(WorldMatrix, D3DMath_MatrixInvert(Parent.WorldMatrix));
        end
    {$ENDIF}
      else
        result := WorldMatrix;
    end;
end;

//姿勢の設定
//Setting position

procedure TSXFrame.SetOrientation(ref: TSXFrame; const vecZ: TD3DVector;
  const vecY: TD3DVector);
var
  tmpMat: TD3DMATRIX; //refフレームとの相対変換行列 //relative to ref frame transformation matrix
  vTrans: array[0..3] of Single; //平行移動成分の保存用 //Translation component storage
  vecX: TD3DVECTOR;
begin
{$IFDEF USE_S_MATHPACK}
  vecX := NowNormalize(NowCrossProduct(vecY, vecZ));
{$ELSE}
  vecX := D3DMath_VecNormalize(D3DMath_Vec3Cross(vecY, vecZ));
{$ENDIF}
  if ref = Parent then
  begin

    //親への姿勢を作るだけなら、簡単
    //If you just make a commitment to parents, simply

    with FMatrix do
    begin
      _11 := vecX.X; _12 := vecX.Y; _13 := vecX.Z;
      _21 := vecY.X; _22 := vecY.Y; _23 := vecY.Z;
      _31 := vecZ.X; _32 := vecZ.Y; _33 := vecZ.Z;
    end;

  end
  else
  begin

    //平行移動成分の保存
    //Save the translation component

    vTrans[0] := FMatrix._41;
    vTrans[1] := FMatrix._42;
    vTrans[2] := FMatrix._43;

    //変換
    //transformation
    with tmpMat do
    begin
      _11 := vecX.X; _12 := vecX.Y; _13 := vecX.Z; _14 := 0;
      _21 := vecY.X; _22 := vecY.Y; _23 := vecY.Z; _24 := 0;
      _31 := vecZ.X; _32 := vecZ.Y; _33 := vecZ.Z; _34 := 0;
      _41 := vTrans[0]; _42 := vTrans[1]; _43 := vTrans[2]; _44 := 1;
    end;

    SetTransform(ref, tmpMat);

    //Restoring the translation component

    with FMatrix do
    begin
      _41 := vTrans[0]; _42 := vTrans[1]; _43 := vTrans[2];
    end;

  end;

end;

//位置の設定
//Set Position

procedure TSXFrame.SetTranslation(ref: TSXFrame; const pos: TD3Dvector);
var
  tmpMat: TD3DMATRIX; //refフレームとの相対変換行列 //relative to ref frame transformation matrix
  origMat: TD3DMATRIX; //For postural

begin

  if ref = Parent then
  begin

    //親へのトランスレーションを作るだけなら、簡単
    //If you only make the translation to the parent easily

    with FMatrix do
    begin
      _41 := pos.X; _42 := pos.Y; _43 := pos.Z;
    end;

  end
  else
  begin

    origMat := FMatrix;
    tmpMat := FMatrix;

    with tmpMat do
    begin
      _41 := pos.X; _42 := pos.Y; _43 := pos.Z;
    end;

    SetTransform(ref, tmpMat);

    with FMatrix do
    begin
      _11 := OrigMat._11; _12 := OrigMat._12; _13 := OrigMat._13;
      _21 := OrigMat._21; _22 := OrigMat._22; _23 := OrigMat._23;
      _31 := OrigMat._31; _32 := OrigMat._32; _33 := OrigMat._33;
    end;
  end;
end;

procedure TSXFrame.GetOrientation(ref: TSXFrame; var vecZ,
  vecY: TD3DVector);
var
  tmpMat: TD3DMATRIX; //Results calculated buffer
begin

  tmpMat := GetTransform(ref);

  with vecY, tmpMat do
  begin
    X := _21; Y := _22; Z := _23;
  end;

  with vecZ, tmpMat do
  begin
    X := _31; Y := _32; Z := _33;
  end;
end;

//姿勢だけをマトリクスで与える
//Just give the attitude matrix

procedure TSXFrame.SetOrientationMatrix(ref: TSXFrame;
  const mat: TD3DMATRIX);
var
  pushedV: TD3DVector; //平行移動分保存用  //Save Translates for minutes
begin

  //保存
  //Save
  with pushedV do
  begin
    x := FMatrix._41; y := FMatrix._42; z := FMatrix._43;
  end;

  if ref = Self then
  begin
    //自分への変換行列
    //His conversion matrix

    {$IFDEF USE_S_MATHPACK}
    FMatrix := NowCompositeMatrix(mat, FMatrix);
    {$ELSE}
    FMatrix := D3DMath_MatrixMultiply(mat, FMatrix)
    {$ENDIF}

  end
  else
    if ref = Parent then
    begin
      //親への変換行列
      //Transformation matrix to the parent

      FMatrix := mat;

    end
    else
    begin

      //自分→ref→ワールド→親
      //My→ref →World →Parent

      if Parent <> nil then
      begin
        if ref <> nil then
        {$IFDEF USE_S_MATHPACK}
          FMatrix := NowCompositeMatrix(
            NowCompositeMatrix(mat, ref.WorldMatrix),
            NowInvMatrix(Parent.WorldMatrix))
        {$ELSE}
        begin
          FMatrix := D3DMath_MatrixMultiply(D3DMath_MatrixMultiply(mat, ref.WorldMatrix), D3DMath_MatrixInvert(Parent.WorldMatrix))
        end
        {$ENDIF}
        else
        {$IFDEF USE_S_MATHPACK}
          FMatrix := NowCompositeMatrix(mat, NowInvMatrix(Parent.WorldMatrix));
        {$ELSE}
        begin
          FMatrix := D3DMath_MatrixMultiply(mat, D3DMath_MatrixInvert(Parent.WorldMatrix));
        end
        {$ENDIF}
      end
      else
      begin
        if ref <> nil then
        {$IFDEF USE_S_MATHPACK}
          FMatrix := NowCompositeMatrix(mat, ref.WorldMatrix)
        {$ELSE}
        begin
          FMatrix := D3DMath_MatrixMultiply(mat, ref.WorldMatrix)
        end
        {$ENDIF}
        else
          FMatrix := mat;
      end;

    end;

  //復元
  //Restore
  with pushedV do
  begin
    FMatrix._41 := x; FMatrix._42 := y; FMatrix._43 := z;
  end;
end;


function TSXFrame.GetTranslation(ref: TSXFrame): TD3DVECTOR;
var
  tmpMat: TD3DMATRIX; //結果算出用バッファ Results calculated buffer
begin

  if ref = Parent then
  begin
    result.X := FMatrix._41;
    result.Y := FMatrix._42;
    result.Z := FMatrix._43;
  end
  else
  begin
    tmpMat := GetTransform(ref);
    result.X := tmpMat._41;
    result.Y := tmpMat._42;
    result.Z := tmpMat._43;
  end;

end;

//フレーム内の座標→ワールド座標
//Coordinates in world coordinate frame

function TSXFrame.LocalToWorld(vec: TD3DVector): TD3DVector;
begin
  {$IFDEF USE_S_MATHPACK}
  Result := NowHeteroginize(NowTransform(NowHomoginize(vec), WorldMatrix));
  {$ELSE}
  Result := D3DMath_VecHeterogenize(D3DMath_VecTransform(D3DMath_VecHomogenize(vec), WorldMatrix))
  {$ENDIF}
end;

//ワールド座標→フレーム内の座標
//Coordinates in world coordinate frame

function TSXFrame.WorldToLocal(vec: TD3DVector): TD3DVector;
begin
  {$IFDEF USE_S_MATHPACK}
  Result := NowHeteroginize(NowTransform(NowHomoginize(vec), NowInvMatrix(WorldMatrix)));
  {$ELSE}
  Result := D3DMath_VecHeterogenize(D3DMath_VecTransform(D3DMath_VecHomogenize(vec), D3DMath_MatrixInvert(WorldMatrix)));
  {$ENDIF}
end;

//親フレームの変更
//Changing the parent frame

procedure TSXFrame.SetParent(const Value: TSXFrame);

  //先祖リストを再帰的に修正する
  //Fix recursive ancestor list

  procedure RebuildAncestors(me: TSXFrame);
  var
    i: Integer;
  begin
    for i := 0 to me.Children.Count - 1 do
    begin
      //ヲレの先祖を先祖と崇めなさい
      //Ancestor worship ancestors and record your Wo

      me.Children[i].Ancestors.Assign(me.Ancestors);
      //ヲレを親と崇めなさい
      //Users report your parents to revere

      me.Children[i].Ancestors.Add(me);
      //子々孫々に渡ってそうしたまへ
      //Sometimes we do that across to our children grandchildren

      RebuildAncestors(me.Children[i]);
    end;
  end;

begin
  //元の親のリストから外す
  //Removed from the list of the original parent

  if FParent <> nil then
    FParent.Children.Delete(FParent.Children.IndexOf(Self));


  if Value <> nil then
  begin
    //新しい親のリストに加える
    //Add to the list of new parent

    Value.Children.Add(Self);
    //先祖リストを変える
    //Changing the list of ancestors

    Ancestors.Assign(Value.Ancestors);
    Ancestors.Add(Value);
  end
  else
  begin
    Ancestors.Clear;
  end;

  //自分に子供がいるなら、それらの先祖リストも変える
  //If you have children yourself, they also change the list of ancestors

  RebuildAncestors(Self);

  FParent := Value;
end;

//このフレームをカメラにした場合のビュー行列を計算
//When calculating the view matrix of the camera frame

function TSXFrame.ViewMatrix: TD3DMatrix;
begin
  {$IFDEF USE_S_MATHPACK}
  Result := NowInvMatrix(WorldMatrix);
  {$ELSE}
  Result := D3DMath_MatrixInvert(WorldMatrix)
  {$ENDIF}
end;

{ TSXFrameList }

//コピー
//Copy

procedure TSXFrameList.Assign(source: TSXFrameList);
var
  i: Integer;
begin
  Self.Clear;

  for i := 0 to source.Count - 1 do
  begin
    Self.Add(Pointer(source.Frames[i]));
  end;
end;

constructor TSXFrameList.Create;
begin
  inherited;
end;

destructor TSXFrameList.Destroy;
begin
  inherited;
end;

function TSXFrameList.GetFrame(idx: Integer): TSXFrame;
begin
  result := Items[idx];
end;

procedure TSXFrameList.SetFrame(idx: Integer; const Value: TSXFrame);
begin
  Items[idx] := Pointer(Value);
end;

{ TSXScene }

constructor TSXScene.Create(DDCompo: TDXDRaw);
begin
  inherited Create;

  AlphaQueue := TSXRenderingQueue.Create(DDCompo, Self);
  OpaqueQueue := TSXRenderingQueue.Create(DDCompo, Self);
  AddQueue := TSXRenderingQueue.Create(DDCompo, Self);
  SubQueue := TSXRenderingQueue.Create(DDCompo, Self);

  {
  MeshProcessor:=TSXMesh.Create(DDCompo);
  MeshProcessor.VertexSize:=Sizeof(D3DTLVERTEX);
  MeshProcessor.FVF:=D3DFVF_TLVERTEX;
  MeshProcessor.SetSize(65535,65535); //(^^;)

  MeshProcessorMT:=TSXMesh.Create(DDCompo);
  MeshProcessorMT.VertexSize:=Sizeof(TSXTLVertexMT);
  MeshProcessorMT.FVF:=FVF_SXTLVertexMT;
  MeshProcessorMT.SetSize(65535,65535);
  }

  FCamera := nil;
  FOwner := DDCompo;
end;

destructor TSXScene.Destroy;
begin

  AlphaQueue.Free;
  OpaqueQueue.Free;
  AddQueue.Free;
  SubQueue.Free;

  //MeshProcessor.Free;
  //MeshProcessorMT.Free;

  inherited;
end;

//描画

procedure TSXScene.Render(rootFrame: TSXFrame);
var
  viewMat: TD3DMATRIX;
  curTexture: TDirect3DTexture2;
  curMaterial: TD3DMATERIAL7;
  curBlendMode: TRenderType;

  procedure QueingFrame(frame: TSXFrame; const mat: TD3DMATRIX; RSBind, TexBind, MatBind: Boolean);
  var
    i: Integer;
    meshM: TD3DMATRIX;
  begin

    //子フレーム無し、かつ、描画するメッシュなしなら、何もしない
    //Visibilityが「子供もひっくるめて隠す」でも何もしない
    //ただし、ビルボードがくっついてる時は、マトリクスの合成だけ行う
    if (not frame.BBAttached) then
      if ((frame.Children.Count = 0) and (frame.Mesh = nil)) or (frame.Visibility = sxvHide) then
        exit;

    //変換行列の計算
    {$IFDEF USE_S_MATHPACK}
    frame.RenderedMatrix := NowCompositeMatrix(frame.Matrix, mat);
    {$ELSE}
    frame.RenderedMatrix := D3DMath_MatrixMultiply(frame.Matrix, mat);
    {$ENDIF}


    //メッシュの描画
    if frame.Mesh <> nil then
    begin
      {$IFDEF USE_S_MATHPACK}
      meshM := NowCompositeMatrix(frame.MeshMatrix, frame.RenderedMatrix);
      {$ELSE}
      meshM := D3DMath_MatrixMultiply(frame.MeshMatrix, frame.RenderedMatrix);
      {$ENDIF}
      //テクスチャがあるなら、貼り付ける。「親のテクスチャ使用」を強制されてないなら
      if not TexBind then
        curTexture := frame.Texture;

      //マテリアルを設定する
      if not MatBind then
        curMaterial := frame.Material;

      //レンダリングステートの設定
      if not RSBind then
        curBlendMode := frame.BlendMode;

      //キューに放り込む
      if frame.Visibility = sxvShow then
      begin
        case curBlendMode of
          rtAdd: AddQueue.PushMesh(frame.Mesh, frame, meshM, curTexture, curMaterial, frame.OnRenderMesh);
          rtBlend: AlphaQueue.PushMesh(frame.Mesh, frame, meshM, curTexture, curMaterial, frame.OnRenderMesh);
          rtDraw: OpaqueQueue.PushMesh(frame.Mesh, frame, meshM, curTexture, curMaterial, frame.OnRenderMesh);
          rtSub: SubQueue.PushMesh(frame.Mesh, frame, meshM, curTexture, curMaterial, frame.OnRenderMesh);
        end;
      end;
    end;

    //子供の描画
    for i := 0 to frame.Children.Count - 1 do
    begin
      QueingFrame(frame.Children[i], frame.RenderedMatrix, RSBind or frame.BindRenderState, TexBind or frame.BindTexture, MatBind or frame.BindMaterial);
    end;
  end;

begin

  if FCamera = nil then
  begin
    //DDDD_PutDebugMessage('SXLib: カメラフレームが設定されていません');
    exit;
  end;

  //ビュー行列の作成…(ワールド座標系でのカメラフレームの姿勢)の逆
  //Create a view matrix (camera position in world coordinate frame), the inverse

  viewMat := CameraFrame.ViewMatrix;

  FOwner.D3DDevice7.SetTransform(D3DTRANSFORMSTATE_VIEW, viewMat);

  //再帰的にキューに入れる
  //Recursively queued

  if rootFrame.Parent = nil then
    QueingFrame(rootFrame, D3DUtil_SetIdentityMatrix, false, false, false)
  else
    QueingFrame(rootFrame, rootFrame.Parent.WorldMatrix, false, false, false);

  { キューに入ってる物体を描く }
  { I draw the object in the queue }

  /////不透明体
  //Opaque
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_ZENABLE, 1); //Z比較あり
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_ZWRITEENABLE, 1); //Z書き込みあり

  //ブレンドなし
  //No Blending
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_BLENDENABLE, 0);

  OpaqueQueue.Render(viewMat, FVP);

  /////加算合成体
  //Body additive synthesis
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_ZWRITEENABLE, 0); //Z書き込みなし

  //ブレンドの設定
  //Set of Blend
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_BLENDENABLE, 1);

  FOwner.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG1, DWord(D3DTA_TEXTURE));
  FOwner.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG2, DWord(D3DTA_DIFFUSE));
  FOwner.D3DDevice7.SetTextureStageState(0, D3DTSS_COLOROP, DWord(D3DTOP_MODULATE));

  FOwner.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG1, DWord(D3DTA_TEXTURE));
  FOwner.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG2, DWord(D3DTA_DIFFUSE));
  FOwner.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAOP, DWord(D3DTOP_MODULATE));

  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, DWord(D3DBLEND_ONE));
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_DESTBLEND, DWord(D3DBLEND_ONE));

  AddQueue.Render(viewMat, FVP);

  //半透明体
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, DWord(D3DBLEND_SRCALPHA));
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_DESTBLEND, DWord(D3DBLEND_INVSRCALPHA));

  AlphaQueue.Render(viewMat, FVP);

  //減算合成体…減算はニセ減算だけど(^^;)
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, DWord(D3DBLEND_ZERO));
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_DESTBLEND, DWord(D3DBLEND_INVSRCCOLOR));

  SubQueue.Render(viewMat, FVP);

  //テクスチャに何も指定しない状態で、一連のレンダリングを終える
  FOwner.D3DDevice7.SetTexture(0, nil);
end;

procedure TSXScene.Clear(dwFlags: DWord; color: DWORD; z: Single; stencil: DWord);
var
  r: TD3DRect;
begin
  with r do
  begin
    x1 := FVP.dwX;
    y1 := FVP.dwY;
    x2 := FVP.dwX + FVP.dwWidth;
    y2 := FVP.dwY + FVP.dwHeight;
  end;

  FOwner.D3DDevice7.Clear(1, @r, dwFlags, color, z, stencil);
end;

//透視変換の設定

procedure TSXScene.SetProjection(fov, aspect, nearZ, farZ: Single); //透視変換の設定
var
  q, w, h: Single;
begin

  q := farZ / (farZ - nearZ);
  w := aspect * Cos(fov * 0.5) / Sin(fov * 0.5);
  h := Cos(fov * 0.5) / Sin(fov * 0.5);

  FProjectionMatrix := D3DUtil_SetIdentityMatrix;

  FProjectionMatrix._11 := w; //
  FProjectionMatrix._22 := h; //
  FProjectionMatrix._33 := q; //   Q = Zf / (Zf-Zn)
  FProjectionMatrix._34 := 1.0;
  FProjectionMatrix._43 := -q * nearZ; //   -QZn
  FProjectionMatrix._44 := 0.0;

  FOwner.D3DDevice7.SetTransform(D3DTRANSFORMSTATE_PROJECTION, FProjectionMatrix);
end;

procedure TSXScene.SetViewPort(left, top, right, bottom: DWord);
begin
  ZeroMemory(@FVP, sizeof(FVP));

  with FVP do
  begin
    dwX := left;
    dwY := top;
    dwWidth := right - left;
    dwHeight := bottom - top;
    dvMinZ := 0;
    dvMaxZ := 1.0;
  end;

  FOwner.D3DDevice7.SetViewport(FVP);
end;

//D3D解放(解像度変更)からのリカバリ

procedure TSXScene.Recover;
begin
  FOwner.D3DDevice7.SetViewport(FVP);
  FOwner.D3DDevice7.SetTransform(D3DTRANSFORMSTATE_PROJECTION, FProjectionMatrix);
end;

//ビルボードを押し込む

procedure TSXScene.PushBillboard(blendMode: TRenderType; ref: TSXFrame;
  pos: TD3DVector; points: array of TSXVertexBB; tex: TDirect3DTexture2);
begin
  case blendMode of
    rtAdd: AddQueue.PushBillboard(ref, pos, tex, points);
    rtBlend: AlphaQueue.PushBillboard(ref, pos, tex, points);
    rtDraw: OpaqueQueue.PushBillboard(ref, pos, tex, points);
    rtSub: SubQueue.PushBillboard(ref, pos, tex, points);
  end;
  //フラグを立てる
  ref.BBAttached := True;

end;

//球体の可視判定

function TSXScene.SphereVisibility(ref: TSXFrame; pos: TD3DVector;
  radius: Single; depth: Single): Boolean;
var
  viewM: TD3DMATRIX; //ref.posを視野座標系に変換する行列
  projM: TD3DMATRIX; //透視変換行列(画角ゲット用)

  p: TD3DVector;
  fovH, fovV: Single; //画角
  cosFovH, sinFovH, cosFovV, sinFovV: Single;
begin
  //まず、視野座標系に変換する
  {$IFDEF USE_S_MATHPACK}
  viewM := NowCompositeMatrix(ref.WorldMatrix, NowInvMatrix(CameraFrame.WorldMatrix));
  p := NowHeteroginize(NowTransform(NowHomoginize(pos), viewM));
  {$ELSE}
  viewM := D3DMath_MatrixMultiply(ref.WorldMatrix, D3DMath_MatrixInvert(CameraFrame.WorldMatrix));
  p := D3DMath_VecHeterogenize(D3DMath_VecTransform(D3DMath_VecHomogenize(pos), viewM));
  {$ENDIF}

  //視界の後方や、depthより遠くにあるってのは論外
  if (p.z < -radius) or (p.z > depth + radius) then
  begin
    Result := False;
    Exit;
  end;

  //縦・横の画角を求める
  FOwner.D3DDevice7.GetTransform(D3DTRANSFORMSTATE_PROJECTION, projM);
  fovH := ArcTan(1.0 / projM._11);
  fovV := ArcTan(1.0 / projM._22);

  //画角のSin,Cosを出しておく
  SinFovH := Sin(fovH); CosFovH := Cos(fovH);
  SinFovV := Sin(fovV); CosFovV := Cos(fovV);

  //XZ平面での判定…画角分だけ球の中心を回転させた時、コーンの中心から球の中心までが、球の半径の値以下になるかを見る
  if ((p.x * CosFovH - p.z * SinFovH) > radius) or ((p.x * CosFovH + p.z * SinFovH) < -radius) then
  begin
    Result := False;
    Exit;
  end;

  //YZ平面での判定
  if ((p.y * CosfovV - p.z * SinfovV) > radius) or ((p.y * CosfovV + p.z * SinfovV) < -radius) then
  begin
    Result := False;
    Exit;
  end;

  Result := True;
end;

{ TSXLight }

constructor TSXLight.Create(DDCompo: TDXDraw; index: DWord);
begin
  inherited Create;

  FOwner := DDCompo;
  FIndex := index;
  FEnabled := False;
  FUpdate := True;

  //デフォ値の設定
  ZeroMemory(@Params, Sizeof(Params));
  with Params do
  begin
    dltType := D3DLIGHT_DIRECTIONAL;

    dcvDiffuse.r := 1.0;
    dcvDiffuse.g := 1.0;
    dcvDiffuse.b := 1.0;
    {$IFDEF USE_S_MATHPACK}
    dvDirection := Vector(0, 0, 1);
    {$ELSE}
    dvDirection := MakeD3DVector(0, 0, 1);
    {$ENDIF}
  end;
end;

destructor TSXLight.Destroy;
begin
  inherited;
end;

//D3Dにライトを登録

procedure TSXLight.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;

  FOwner.D3DDevice7.SetLight(FIndex, Params);
  FOwner.D3DDevice7.LightEnable(FIndex, FEnabled);

end;

//お便利るーちんず

procedure TSXLight.SetupDiffuse(_R, _G, _B: Single);
begin
  with Params.dcvDiffuse do
  begin
    dvR := _R;
    dvG := _G;
    dvB := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupSpecular(_R, _G, _B: Single);
begin
  with Params.dcvSpecular do
  begin
    dvR := _R;
    dvG := _G;
    dvB := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupAmbient(_R, _G, _B: Single);
begin
  with Params.dcvAmbient do
  begin
    dvR := _R;
    dvG := _G;
    dvB := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupColors(difR, difG, difB, specR, specG, specB, ambR,
  ambG, ambB: Single);
begin
  with Params.dcvDiffuse do
  begin
    dvR := difR;
    dvG := difG;
    dvB := difB;
  end;
  with Params.dcvSpecular do
  begin
    dvR := specR;
    dvG := specG;
    dvB := specB;
  end;
  with Params.dcvAmbient do
  begin
    dvR := ambR;
    dvG := ambG;
    dvB := ambB;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupRanges(range, att0, att1, att2: Single);
begin
  with Params do
  begin
    dvRange := range;
    dvAttenuation0 := att0;
    dvAttenuation1 := att1;
    dvAttenuation2 := att2;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupDirectional(dir: TD3DVector);
begin
  Params.dltType := D3DLIGHT_DIRECTIONAL;
  Params.dvDirection := dir;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupPoint(pos: TD3DVector);
begin
  Params.dltType := D3DLIGHT_POINT;
  Params.dvPosition := pos;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.SetupSpot(pos, dir: TD3DVector; theta, phi,
  falloff: Single);
begin
  Params.dltType := D3DLIGHT_SPOT;
  Params.dvDirection := dir;

  Params.dvTheta := theta;
  Params.dvPhi := phi;
  Params.dvFalloff := falloff;

  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

//フレームの位置・向きにセット

procedure TSXLight.FitFrame(target: TSXFrame);
var
  mat: TD3DMATRIX;
begin

  if target = nil then
    mat := D3DUtil_SetIdentityMatrix
  else
    mat := target.WorldMatrix;
  {$IFDEF USE_S_MATHPACK}
  Params.dvDirection := Vector(mat._31, mat._32, mat._33);
  Params.dvPosition := Vector(mat._41, mat._42, mat._43);
  {$ELSE}
  Params.dvDirection := MakeD3DVector(mat._31, mat._32, mat._33);
  Params.dvPosition := MakeD3DVector(mat._41, mat._42, mat._43);
  {$ENDIF}
  if FUpdate then
    FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

procedure TSXLight.BeginUpdate;
begin
  FUpdate := False;
end;

procedure TSXLight.EndUpdate;
begin
  FUpdate := True;
  FOwner.D3DDevice7.SetLight(FIndex, Params);
end;

{ TSXLightGroup }

constructor TSXLightGroup.Create(DDCompo: TDXDraw; capacity: DWord);
var
  i: Integer;
begin
  inherited Create;

  FOwner := DDCompo;
  FCapacity := capacity;
  SetLength(FLights, capacity);

  for i := 0 to capacity - 1 do
  begin
    FLights[i] := TSXLight.Create(FOwner, i);
  end;
end;

destructor TSXLightGroup.Destroy;
var
  i: Integer;
begin

  for i := 0 to FCapacity - 1 do
  begin
    FLights[i].Free;
  end;

  FLights := nil;

  inherited;
end;

procedure TSXLightGroup.DisableAll;
var
  i: Integer;
begin
  for i := 0 to FCapacity - 1 do
  begin
    FLights[i].Enabled := True;
  end;
end;

procedure TSXLightGroup.EnableAll;
var
  i: Integer;
begin
  for i := 0 to FCapacity - 1 do
  begin
    FLights[i].Enabled := False;
  end;
end;

function TSXLightGroup.GetLights(idx: DWord): TSXLight;
begin
  //範囲チェック
  if idx >= FCapacity then
  begin
    //DDDD_PutDebugMessage('TSXLightGroup @ SXLib: 範囲外のライトを参照しようとしました');
    result := nil;
    exit;
  end;

  result := FLights[idx];
end;


//Enabledじゃないライトを探索

function TSXLightGroup.GetUnusedLight: TSXLight;
var
  i: Integer;
begin

  for i := 0 to FCapacity - 1 do
  begin
    if not FLights[i].Enabled then
    begin
      result := FLights[i];
      exit;
    end;
  end;

  result := nil;
end;

//スペキュラ強度の設定
{
procedure TSXLightGroup.SetSpecularPower(const Value: Single);
var
  mtrl:D3DMATERIAL7;
begin
  FSpecularPower := Value;

  ZeroMemory(@mtrl, Sizeof(mtrl));
  mtrl.power:=FSpecularPower;

  FOwner.D3DDevice.SetMaterial(@mtrl);
end;
}

procedure TSXLightGroup.Recover;
var
  i: Integer;
begin

  for i := 0 to FCapacity - 1 do
  begin
    if FLights[i].Enabled then
      FLights[i].Enabled := True;
  end;

//  SpecularPower:=FSpecularPower;
end;

{ TSXMatetial }

constructor TSXMaterial.Create(DDCompo: TDXDraw);
begin
  ZeroMemory(@Params, Sizeof(Params));
  FOwner := DDCompo;
  FUpdate := True;
end;

procedure TSXMaterial.SetupAmbient(_R, _G, _B: Single);
begin
  with Params.dcvAmbient do
  begin
    R := _R; G := _G; B := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetMaterial(Params);
end;

procedure TSXMaterial.SetupDiffuse(_R, _G, _B: Single);
begin
  with Params.dcvDiffuse do
  begin
    R := _R; G := _G; B := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetMaterial(Params);
end;

procedure TSXMaterial.SetupEmissive(_R, _G, _B: Single);
begin
  with Params.dcvEmissive do
  begin
    R := _R; G := _G; B := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetMaterial(Params);
end;

procedure TSXMaterial.SetupSpecular(_R, _G, _B: Single);
begin
  with Params.dcvSpecular do
  begin
    R := _R; G := _G; B := _B;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetMaterial(Params);
end;

procedure TSXMaterial.SetupSpecularPower(pow: Single);
begin
  with Params do
  begin
    dvPower := pow;
  end;

  if FUpdate then
    FOwner.D3DDevice7.SetMaterial(Params);
end;


procedure TSXMaterial.SetupColors(difR, difG, difB, specR, specG, specB,
  ambR, ambG, ambB, emsR, emsG, emsB, pow: Single);
begin

  with Params.dcvDiffuse do
  begin
    dvR := difR;
    dvG := difG;
    dvB := difB;
  end;
  with Params.dcvSpecular do
  begin
    dvR := specR;
    dvG := specG;
    dvB := specB;
  end;
  with Params.dcvAmbient do
  begin
    dvR := ambR;
    dvG := ambG;
    dvB := ambB;
  end;
  with Params.dcvEmissive do
  begin
    dvR := emsR;
    dvG := emsG;
    dvB := emsB;
  end;

  Params.dvPower := pow;

  if FUpdate then
    FOwner.D3DDevice7.SetMaterial(Params);

end;

procedure TSXMaterial.BeginUpdate;
begin
  FUpdate := False;
end;

procedure TSXMaterial.EndUpdate;
begin
  FUpdate := True;
  FOwner.D3DDevice7.SetMaterial(Params);
end;

{ ヘルパー関数 }

function MakeMaterial(difR, difG, difB, specR, specG, specB, ambR, ambG, ambB, emsR, emsG, emsB, pow: Single): TD3DMATERIAL7;
begin
  with Result.dcvDiffuse do
  begin
    dvR := difR;
    dvG := difG;
    dvB := difB;
    dvA := 1.0;
  end;
  with Result.dcvSpecular do
  begin
    dvR := specR;
    dvG := specG;
    dvB := specB;
    dvA := 1.0;
  end;
  with Result.dcvAmbient do
  begin
    dvR := ambR;
    dvG := ambG;
    dvB := ambB;
    dvA := 1.0;
  end;
  with Result.dcvEmissive do
  begin
    dvR := emsR;
    dvG := emsG;
    dvB := emsB;
    dvA := 1.0;
  end;

  Result.dvPower := pow;
end;

{ TSXRenderingQueue }

//コンストラクタ

constructor TSXRenderingQueue.Create(AOwner: TDXDraw; _Scene: TSXScene);
begin
  inherited create;

  FOwner := AOwner;
  Scene := _Scene;

  //デフォ値の代入
  BillboardCapacity := 32;
  MeshCapacity := 32;

  FBillboardCount := 0;
  FMeshCount := 0;
end;

//デストラクタ

destructor TSXRenderingQueue.Destroy;
begin
  BillboardQueue := nil;
  MeshQueue := nil;

  inherited;
end;

//何もせずに、中身だけ消す

procedure TSXRenderingQueue.Flush;
begin
  FBillboardCount := 0;
  FMeshCount := 0;
end;

//ビルボードを入れる

procedure TSXRenderingQueue.PushBillboard(ref: TSXFrame; pos: TD3DVector;
  tex: TDirect3DTexture2; pts: array of TSXVertexBB); //ビルボード
begin
  //必要なら拡張する
  if BillboardCount >= BillboardCapacity then
    BillboardCapacity := BillboardCapacity * 2;


  BillboardQueue[FBillboardCount].tex := tex;
  BillboardQueue[FBillboardCount].ref := ref;
  BillboardQueue[FBillboardCount].pos := pos;
  Move(pts, BillboardQueue[FBillboardCount].Pts, Sizeof(TSXVertexBB) * 4); //4頂点分コピー

  Inc(FBillboardCount);
end;

//メッシュを入れる

procedure TSXRenderingQueue.PushMesh(mesh: TSXMesh; frame: TSXFrame; mat: TD3DMatrix;
  tex: TDirect3DTexture2; mtrl: TD3DMATERIAL7; event: TSXRenderMeshEvent);
begin
  //必要なら拡張する
  if MeshCount >= MeshCapacity then
    MeshCapacity := MeshCapacity * 2;

  MeshQueue[FmeshCount].mat := mat;
  MeshQueue[FmeshCount].mesh := mesh;
  MeshQueue[FmeshCount].mtrl := mtrl;
  MeshQueue[FmeshCount].tex := tex;
  MeshQueue[FmeshCount].OnRender := event;
  MeshQueue[FMeshCount].frame := frame;

  Inc(FMeshCount);
end;

//ビルボード用の情報入れをサイズを変える

procedure TSXRenderingQueue.SetBillBoardCapacity(const Value: Integer);
begin
  FBillboardCapacity := Value;
  SetLength(BillboardQueue, Value);
end;

//メッシュ用の情報入れをサイズを変える

procedure TSXRenderingQueue.SetMeshCapacity(const Value: Integer);
begin
  FMeshCapacity := Value;
  SetLength(MeshQueue, Value);
end;

//描画

procedure TSXRenderingQueue.Render(viewMat: TD3DMATRIX; viewParam: TD3DVIEWPORT7);
var
  i, j: Integer;
  prevTex: TDirect3DTexture2; //前回使ったテクスチャへの参照  //With reference to the previous texture
  prevSpec: Boolean; //前回描画したものは、スペキュラを計算したか //The last drawing was either calculated specular
  prevLit: Boolean; //前回描画したものは、ライティングの計算をしたか //Was drawn last, or the lighting calculations
  prevFrame: TSXFrame; //直前に描画したビルボードの入ってたフレーム //I was drawn into the frame just before the billboard
  center: {$IFDEF USE_S_MATHPACK}THgVector{$ELSE}TD3DHVector{$ENDIF};
  pts: array[0..3] of TD3DTLVERTEX;
  m: TD3DMATRIX;
  projM, screenM, viewProjScreenM: TD3DMATRIX;
begin

  //メッシュの描画

  prevTex := nil;
  FOwner.D3DDevice7.SetTexture(0, nil);

  prevSpec := True;
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_SPECULARENABLE, DWord(True));

  prevLit := True;
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_LIGHTING, DWord(True));

  for i := 0 to MeshCount - 1 do
  begin

    //ライティング
    if prevLit <> MeshQueue[i].Frame.Lighting then
    begin
      FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_LIGHTING, DWord(MeshQueue[i].Frame.Lighting));
      prevLit := MeshQueue[i].Frame.Lighting;
    end;

    //スペキュラつける？
    if prevSpec <> MeshQueue[i].Frame.Specular then
    begin
      FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_SPECULARENABLE, DWord(MeshQueue[i].Frame.Specular));
      prevSpec := MeshQueue[i].Frame.Specular;
    end;

    //行列の設定
    FOwner.D3DDevice7.SetTransform(D3DTRANSFORMSTATE_WORLD, (MeshQueue[i].mat));

    //マテリアルの設定
    FOwner.D3DDevice7.SetMaterial((MeshQueue[i].Mtrl));

    //テクスチャがあるなら、貼り付ける。
    if MeshQueue[i].tex <> prevTex then
    begin
      if MeshQueue[i].tex <> nil then
        FOwner.D3DDevice7.SetTexture(0, MeshQueue[i].tex.Surface.IDDSurface7)
      else
        FOwner.D3DDevice7.SetTexture(0, nil);
    end;

    prevTex := MeshQueue[i].tex;

    //イベントハンドラを呼ぶ
    if Assigned(MeshQueue[i].OnRender) then
      MeshQueue[i].OnRender(MeshQueue[i].Frame);

    //描画
    MeshQueue[i].Mesh.Draw(0);

  end;

  //ビルボードの描画

  //ライティングを切る
  FOwner.D3DDevice7.SetRenderState(D3DRENDERSTATE_LIGHTING, DWord(False));

  FOwner.D3DDevice7.GetTransform(D3DTRANSFORMSTATE_PROJECTION, projM);
  ScreenM := D3DUtil_SetIdentityMatrix;
  with ScreenM do
  begin
    _11 := viewParam.dwWidth / 2.0;
    _22 := -(viewParam.dwHeight / 2.0);
    _33 := viewParam.dvMaxZ - viewParam.dvMinZ;
    _41 := viewParam.dwX + viewParam.dwWidth / 2.0;
    _42 := viewParam.dwY + viewParam.dwHeight / 2.0;
    _43 := viewParam.dvMinZ;
  end;

  //視野座標→画面 の変換行列
  {$IFDEF USE_S_MATHPACK}
  viewProjScreenM := NowCompositeMatrix(viewMat, projM);
  viewProjScreenM := NowCompositeMatrix(viewProjScreenM, ScreenM);
  {$ELSE}
  viewProjScreenM := D3DMath_MatrixMultiply(viewMat, projM);
  viewProjScreenM := D3DMath_MatrixMultiply(viewProjScreenM, ScreenM);
  {$ENDIF}
  prevFrame := nil;

  for i := 0 to BillboardCount - 1 do
  begin

    if BillboardQueue[i].ref <> nil then
    begin
      //テクスチャがあるなら、貼り付ける。
      if BillboardQueue[i].Tex <> prevTex then
      begin
        if BillboardQueue[i].Tex <> nil then
          FOwner.D3DDevice7.SetTexture(0, BillboardQueue[i].Tex.Surface.IDDSurface7)
        else
          FOwner.D3DDevice7.SetTexture(0, nil);
      end;
      prevTex := BillboardQueue[i].Tex;


      //ビルボードの中心の視野座標を求める
      if prevFrame <> BillboardQueue[i].ref then
      begin
        {$IFDEF USE_S_MATHPACK}
        m := NowCompositeMatrix(BillboardQueue[i].ref.RenderedMatrix, viewProjScreenM);
        {$ELSE}
        m := D3DMath_MatrixMultiply(BillboardQueue[i].ref.RenderedMatrix, viewProjScreenM);
        {$ENDIF}
        prevFrame := BillboardQueue[i].ref;
      end;
      {$IFDEF USE_S_MATHPACK}
      center := NowHomoginize(BillboardQueue[i].pos);
      center := NowTransform(center, m);
      {$ELSE}
      center := D3DMath_VecHomogenize(BillboardQueue[i].pos);
      center := D3DMath_VecTransform(center, m);
      {$ENDIF}
      //W値が正なら描画
      //W is positive if the drawing
      if center.W > 0 then
      begin
        //ビルボードの中心の画面での座標を求める
        //Find the coordinates of the center of the screen, billboard
        {$IFDEF USE_S_MATHPACK}
        center := NowViewFrustumToScreen(center);
        {$ELSE}
        center := D3DMath_VecViewScreenize(center);
        {$ENDIF}
        for j := 0 to 3 do
        begin
          with BillboardQueue[i].Pts[j] do
          begin
            Pts[j].sx := center.x + BillboardQueue[i].Pts[j].dx * center.W;
            Pts[j].sy := center.y + BillboardQueue[i].Pts[j].dy * center.W;
            Pts[j].sz := center.z;
            Pts[j].rhw := center.w;
            Pts[j].color := color;
            Pts[j].specular := $FF000000;
            Pts[j].tu := tu;
            Pts[j].tv := tv;
          end;
        end;

        FOwner.D3DDevice7.DrawPrimitive(D3DPT_TRIANGLESTRIP, D3DFVF_TLVERTEX, Pts, 4, 0);
      end;

      //参照フレームに付いたフラグを消す
      BillboardQueue[i].ref.BBAttached := False;
    end;
  end;

  //キューを空に
  FMeshCount := 0;
  FBillBoardCount := 0;
end;

{-------------------------------- Primitive Renderer --------------------------}

type
  TIntArray = array[0..$0FFFFFFF] of Integer;
  PIntArray = ^TIntArray;
  TPrimArray = array[0..$FFFFF] of TSXPrimitiveRec;
  PPrimArray = ^TPrimArray;
  TTextureCoordArray = array[0..$FFFFF] of TSXTextureCoordRec;
  PTextureCoordArray = ^TTextureCoordArray;

class function TSXPrimitiveRenderer.SingleRect(x1, y1, x2, y2: Single): TSingleRect;
begin
  with result do
  begin
    Left := x1;
    Top := y1;
    Right := x2;
    Bottom := y2;
  end;
end;

constructor TSXPrimitiveRenderer.Create(DDCompo: TDXDraw; PrimitiveCount: Integer; PatternCount: Integer);
begin
  FDXDraw := DDCompo;
  FMaxPrimitives := PrimitiveCount;
  ZSortBuf := nil;
  ZSortCount := nil;
  PrimCount := 0;

  GetMem(PrimBuf, Sizeof(TSXPrimitiveRec) * PrimitiveCount);
  GetMem(Patterns, Sizeof(TSXTextureCoordRec) * PatternCount);

  ZMax := 0;
  ColorKey := True;
end;

destructor TSXPrimitiveRenderer.Destroy;
begin
  FreeMem(ZSortBuf);
  FreeMem(ZSortCount);
  FreeMem(Patterns);
  FreeMem(PrimBuf);

  inherited;
end;

procedure TSXPrimitiveRenderer.setZMax(v: Integer);
begin
  FZmax := v;

  if ZSortBuf <> nil then
    FreeMem(ZSortBuf);
  if ZSortCount <> nil then
    FreeMem(ZSortCount);

  GetMem(ZSortBuf, (FZMax + 1) * FMaxPrimitives * sizeof(Integer));
  GetMem(ZSortCount, (FZMax + 1) * sizeof(Integer));
end;

//パターンとしてTexのCoordで示される範囲を登録

procedure TSXPrimitiveRenderer.SetPattern(idx: Integer; Tex: TDirect3DTexture2; Coord: TRect);
var
  pPat: PTextureCoord;
begin
  pPat := @(PTextureCoordArray(Patterns)^[idx]);

  with pPat^ do
  begin
    Texture := Tex;
    Top := Coord.Top / Tex.Height;
    Left := Coord.Left / Tex.Width;
    Bottom := Coord.Bottom / Tex.Height;
    Right := Coord.Right / Tex.Width;
  end;

end;

procedure TSXPrimitiveRenderer.Push(Tex: TDirect3DTexture2; p1, p2, p3, p4: TD3DTLVertex; Z: Integer; blend: TRenderType); //TLVertexで四角形を入れる
begin
  with PPrimArray(PrimBuf)^[PrimCount] do
  begin
    Texture := Tex;

    Bound[0] := p1;
    Bound[1] := p2;
    Bound[2] := p3;
    Bound[3] := p4;

    ZOrder := Z;
    BlendMode := blend;
  end;

  Inc(PrimCount);
end;

procedure TSXPrimitiveRenderer.Push2D(Tex: TDirect3DTexture2; p1, p2, p3, p4: TD2DVector; Z: Integer; blend: TRenderType; col: DWord); //2D的な四角形
begin
  with PPrimArray(PrimBuf)^[PrimCount] do
  begin
    Texture := Tex;

    Bound[0] := MakeD3DTLVertex(p1.x, p1.y, 2.0, 0.5, col, 0, 0, 0);
    Bound[1] := MakeD3DTLVertex(p2.x, p2.y, 2.0, 0.5, col, 0, 1, 0);
    Bound[2] := MakeD3DTLVertex(p3.x, p3.y, 2.0, 0.5, col, 0, 0, 1);
    Bound[3] := MakeD3DTLVertex(p4.x, p4.y, 2.0, 0.5, col, 0, 1, 1);

    ZOrder := Z;
    BlendMode := blend;
  end;

  Inc(PrimCount);
end;

//パターンをプッシュ(3次元)

procedure TSXPrimitiveRenderer.PushPattern(iPat: Integer; p1, p2, p3, p4: TD3DHVector; Z: Integer; blend: TRenderType; col: DWord);
var
  pPat: PTextureCoord;
begin
  with PPrimArray(PrimBuf)^[PrimCount] do
  begin

    pPat := @(PTextureCoordArray(Patterns)^[iPat]);
    Texture := pPat^.Texture;

    Bound[0] := MakeD3DTLVertex(p1.x, p1.y, p1.z, p1.w, col, 0, pPat^.Left, pPat^.Top);
    Bound[1] := MakeD3DTLVertex(p2.x, p2.y, p2.z, p2.w, col, 0, pPat^.Right, pPat^.Top);
    Bound[2] := MakeD3DTLVertex(p3.x, p3.y, p3.z, p3.w, col, 0, pPat^.Left, pPat^.Bottom);
    Bound[3] := MakeD3DTLVertex(p4.x, p4.y, p4.z, p4.w, col, 0, pPat^.Right, pPat^.Bottom);

    ZOrder := Z;
    BlendMode := blend;
  end;

  Inc(PrimCount);
end;

procedure TSXPrimitiveRenderer.PushPattern2D(iPat: Integer; p1, p2, p3, p4: TD2DVector; Z: Integer; blend: TRenderType; col: DWord); //パターンをプッシュする
var
  pPat: PTextureCoord;
begin
  with PPrimArray(PrimBuf)^[PrimCount] do
  begin

    pPat := @(PTextureCoordArray(Patterns)^[iPat]);
    Texture := pPat^.Texture;

    Bound[0] := MakeD3DTLVertex(p1.x, p1.y, 2, 0.5, col, 0, pPat^.Left, pPat^.Top);
    Bound[1] := MakeD3DTLVertex(p2.x, p2.y, 2, 0.5, col, 0, pPat^.Right, pPat^.Top);
    Bound[2] := MakeD3DTLVertex(p3.x, p3.y, 2, 0.5, col, 0, pPat^.Left, pPat^.Bottom);
    Bound[3] := MakeD3DTLVertex(p4.x, p4.y, 2, 0.5, col, 0, pPat^.Right, pPat^.Bottom);

    ZOrder := Z;
    BlendMode := blend;
  end;

  Inc(PrimCount);
end;

//パターンをプッシュする(矩形)

procedure TSXPrimitiveRenderer.PushPatternRect(iPat: Integer; rect: TSingleRect; Z: Integer; blend: TRenderType; col: DWord);
var
  pPat: PTextureCoord;
begin
  with PPrimArray(PrimBuf)^[PrimCount] do
  begin

    pPat := @(PTextureCoordArray(Patterns)^[iPat]);
    Texture := pPat^.Texture;

    Bound[0] := MakeD3DTLVertex(rect.Left, rect.Top, 2, 0.5, col, 0, pPat^.Left, pPat^.Top);
    Bound[1] := MakeD3DTLVertex(rect.Right, rect.Top, 2, 0.5, col, 0, pPat^.Right, pPat^.Top);
    Bound[2] := MakeD3DTLVertex(rect.Left, rect.Bottom, 2, 0.5, col, 0, pPat^.Left, pPat^.Bottom);
    Bound[3] := MakeD3DTLVertex(rect.Right, rect.Bottom, 2, 0.5, col, 0, pPat^.Right, pPat^.Bottom);

    ZOrder := Z;
    BlendMode := blend;
  end;

  Inc(PrimCount);
end;

//Z値にしたがってソート

procedure TSXPrimitiveRenderer.BeginRender;
var
  i: Integer;
  pCount: ^Integer; //各レイヤに、いくつ物体があるか
  pSort: ^Integer;
  pPrim: PPrimitive;
begin
  FNPrims := PrimCount;

  //FSortCountのクリア
  pCount := Pointer(ZSortCount);
  ZeroMemory(pCount, Sizeof(Integer) * (FZMax + 1));

  if PrimCount = 0 then
    Exit;

  //ビンソート
  pPrim := @(PPrimArray(PrimBuf)^[PrimCount - 1]);
  for i := PrimCount - 1 downto 0 do
  begin
    pSort := Pointer(ZSortBuf);
    pCount := Pointer(ZSortCount);
    if pPrim^.ZOrder > FZMax then
    begin
      //DDDD_PutDebugMessage(Format('Primitives: Z=%dは無効です、Z値は0から%dの範囲にしてください',[pPrim^.ZOrder,FZMax]));
      continue;
    end;
    Inc(pCount, pPrim^.ZOrder);
    Inc(pSort, pPrim^.ZOrder * FMaxPrimitives + pCount^);
    pSort^ := i; //FSortBuf[z][FSortCount[z]]:=i
    Inc(pCount^); //FSortCount[z]++

    Dec(pPrim);
  end;

end;

//単一のZ値を持つ集合だけ描画

procedure TSXPrimitiveRenderer.RenderOneLayer(Z: Integer);
var
  i: Integer;
  pSort: ^Integer;
  pPrim: PPrimitive;

  prevTexture: TDirect3DTexture2;
  prevBlendMode: TRenderType;
  nPrims: Integer;
begin

  asm
    finit;
  end;

  if Z > FZMax then
  begin
    //DDDD_PutDebugMessage(Format('Render: Z=%dは無効です、Z値は0から%dの範囲にしてください',[Z,FZMax]));
    exit;
  end;

  nPrims := PIntArray(ZSortCount)^[Z];
  if nPrims = 0 then
    Exit;

  //レンダリングステートの設定
  with FDXDraw.D3DDevice7 do
  begin
    SetTexture(0, nil);
    SetRenderState(D3DRENDERSTATE_ZENABLE, INteger(False));
    SetRenderState(D3DRENDERSTATE_ZWRITEENABLE, INteger(False));

    //SetTextureStageState(0, D3DTSS_MAGFILTER, Integer(D3DTFG_POINT));
    //SetTextureStageState(0, D3DTSS_MINFILTER, Integer(D3DTFG_POINT));

    SetTextureStageState(0, D3DTSS_MAGFILTER, Integer(D3DTFG_LINEAR));
    SetTextureStageState(0, D3DTSS_MINFILTER, Integer(D3DTFG_LINEAR));

    SetRenderState(D3DRENDERSTATE_STIPPLEDALPHA, Integer(False));
    SetRenderState(D3DRENDERSTATE_DITHERENABLE, Integer(False));
    SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, Integer(False));
    SetRenderState(D3DRENDERSTATE_COLORKEYENABLE, Integer(ColorKey));
  end;
  prevTexture := nil;
  prevBlendMode := rtDraw;

  pSort := @(PIntArray(ZSortBuf)^[FMaxPrimitives * Z]);
  for i := 0 to nPrims - 1 do
  begin
    pPrim := @(PPrimArray(PrimBuf)^[pSort^]);

    //テクスチャの変更
    if pPrim^.Texture <> prevTexture then
    begin
      if pPrim^.Texture = nil then
        FDXDraw.D3DDevice7.SetTexture(0, nil)
      else
        FDXDraw.D3DDevice7.SetTexture(0, pPrim^.Texture.Surface.IDDSurface7);
      prevTexture := pPrim^.Texture;
    end;

    //ブレンドモードの設定
    if pPrim^.BlendMode <> prevBlendMode then
    begin
      case pPrim^.BlendMode of

        rtDraw:
          begin
            //QD.D3DDevice7.SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, Integer(False));
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, 0);
            //QD.D3DDevice7.SetRenderState(D3DRENDERSTATE_FILLMODE, Integer(D3DFILL_SOLID));
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_COLORKEYENABLE, Integer(True));
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, Integer(D3DBLEND_ONE));
          end;

        rtAdd:
          begin
            if prevBlendMode = rtDraw then
            begin
              FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, Integer(True));

              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG1, Integer(D3DTA_TEXTURE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG2, Integer(D3DTA_DIFFUSE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLOROP, Integer(D3DTOP_MODULATE));

              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG1, Integer(D3DTA_TEXTURE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG2, Integer(D3DTA_DIFFUSE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAOP, Integer(D3DTOP_MODULATE));
            end;
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, Integer(D3DBLEND_ONE)); // ソースブレンド設定
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_DESTBLEND, Integer(D3DBLEND_ONE)); // ディスティネーション設定
          end;

        rtBlend:
          begin
            if prevBlendMode = rtDraw then
            begin
              FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, Integer(True)); //αを有効に☆

              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG1, Integer(D3DTA_TEXTURE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG2, Integer(D3DTA_DIFFUSE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLOROP, Integer(D3DTOP_MODULATE));

              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG1, Integer(D3DTA_TEXTURE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG2, Integer(D3DTA_DIFFUSE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAOP, Integer(D3DTOP_MODULATE));
            end;
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, Integer(D3DBLEND_SRCALPHA)); // ソースブレンド設定
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_DESTBLEND, Integer(D3DBLEND_INVSRCALPHA)); // ディスティネーション設定
          end;

        rtSub:
          begin
            if prevBlendMode = rtDraw then
            begin
              FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_ALPHABLENDENABLE, Integer(True)); //αを有効に☆

              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG1, Integer(D3DTA_TEXTURE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLORARG2, Integer(D3DTA_DIFFUSE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_COLOROP, Integer(D3DTOP_MODULATE));

              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG1, Integer(D3DTA_TEXTURE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAARG2, Integer(D3DTA_DIFFUSE));
              FDXDraw.D3DDevice7.SetTextureStageState(0, D3DTSS_ALPHAOP, Integer(D3DTOP_MODULATE));
            end;
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_SRCBLEND, Integer(D3DBLEND_DESTCOLOR)); // ソースブレンド設定
            FDXDraw.D3DDevice7.SetRenderState(D3DRENDERSTATE_DESTBLEND, Integer(D3DBLEND_ZERO)); // ディスティネーション設定
          end;

      end;
      prevBlendMode := pPrim^.BlendMode;
    end;

    try
      asm
        finit;
      end;
      FDXDraw.D3DDevice7.DrawPrimitive(D3DPT_TRIANGLESTRIP, D3DFVF_TLVERTEX, pPrim^.Bound, 4, 0);
      asm
        finit;
      end;
      Inc(pSort);
    except
      //DDDD_PutDebugMessage('FP Fault');
      Halt;
    end;
  end;

end;

//スタックを空に

procedure TSXPrimitiveRenderer.EndRender;
begin
  PrimCount := 0;
end;

//全部描画

procedure TSXPrimitiveRenderer.Render;
var
  i: Integer;
begin
  BeginRender;
  for i := 0 to FZMax do
    RenderOneLayer(i);
  EndRender;
end;

end.

