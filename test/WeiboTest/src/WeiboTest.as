package
{
	import flash.desktop.NativeApplication;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 *weibo ane test 
	 * @author yueyuanya
	 * @time 2014-4-20
	 * 
	 */	
	[SWF(frameRate="30", backgroundColor="#000000")]
	public class WeiboTest extends Sprite
	{
		private var weibo:WeiboAPI;
		private var txt:TextField;
		public function WeiboTest()
		{
			super();
			
			// 支持 autoOrient
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//add text for test
			txt=new TextField();
			txt.mouseEnabled=false;
			this.addChild(txt);
			txt.textColor=0xffffff;
			txt.x=0;
			txt.multiline=true;
			txt.width=400;
			txt.height=400;
			var tf:TextFormat=new TextFormat();
			tf.size=16;
			txt.defaultTextFormat=tf;
			
			
			
			var btn:Sprite=new Sprite();
			var txt1:TextField=new TextField();
			txt1.autoSize="left";
			txt1.mouseEnabled=false;
			txt1.text="授权";
			txt1.background=true;
			txt1.textColor=0x000000;
			btn.addChild(txt1);
			btn.x=400;
			btn.y=100;
			btn.width=100;
			btn.height=80;
			btn.buttonMode=true;
			btn.addEventListener(MouseEvent.CLICK,onAuthClick);
			this.addChild(btn);
			
			var btn2:Sprite=new Sprite();
			var txt2:TextField=new TextField();
			txt2.autoSize="left";
			txt2.mouseEnabled=false;
			txt2.text="分享";
			txt2.background=true;
			txt2.textColor=0x000000;
			btn2.addChild(txt2);
			btn2.x=400;
			btn2.y=200;
			btn2.width=100;
			btn2.height=80;
			btn2.buttonMode=true;
			btn2.addEventListener(MouseEvent.CLICK,onShareClick);
			this.addChild(btn2);
			//test
			weibo=new WeiboAPI();
			weibo.addEventListener(WeiboAPIEvent.RESPONSE,onResp);
			try{
			if(weibo.isSupport()){
				//appkey redirecturl
				info("issupport true");
				info("registerkey "+weibo.registerKey("1631252558","http://www.sina.com"));
			}else{
				info("不支持ane");
			}
			}catch(e){info("issupport exception")}
			
			//invoke
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,onInvoke);
			
			
		}
		
		private function onAuthClick(e:MouseEvent):void{
			info("auth "+weibo.auth());
		}
		
		private function onShareClick(e:MouseEvent):void{
			info("share "+weibo.share("微博test",new BitmapData(320,320,false,0x0000ff)));
		}
		
		
		
		private function onInvoke(e:InvokeEvent):void{
			trace(e.arguments);
			info("invoke");
			//txt.text+=weibo.call("openURL",e.arguments[0])+"\n";
			if (Capabilities.manufacturer.indexOf("iOS") != -1)//只在ios下采用这种方式
			{
				if (e.arguments != null && e.arguments.length > 0)
				{
					var url:String = e.arguments[0] as String;
					if ( url != null)
					{
						weibo.call("openURL", url);
						info("openurl "+url);
					}
				}
			}
		}
		 
		
		private function onResp(e:Event):void{
			var code:String=weibo.code;
			
			if(code=="respTokenSuccess"){
				info("token "+weibo.level);//授权成功 level为token值
			}
			
			if(code=="respTokenFail"){
				info("token status "+weibo.level);//授权失败 level为状态码
			}
			
			if(code=="respShare"){
				info("share "+weibo.level)
			}
		}
		
		private function info(msg:String):void{
			trace(msg);
			txt.text+=msg+"\n";
			txt.scrollV=txt.maxScrollV;
		}
	}
}