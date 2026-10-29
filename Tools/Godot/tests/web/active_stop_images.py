"""Pixel checks for the shared native/Web active-client-stop fixture."""
import hashlib
from PIL import Image

def verify_images(results, buffers):
    def near(image,x,y,color):assert all(abs(a-b)<=2 for a,b in zip(image.getpixel((round(x),round(y))),color))
    def stamp(image,cx,cy,width,height):
     left,top=cx-width/2,cy-height/2
     for x,y,color in [(left+width*12/640,top+height*12/360,(255,0,0)),(left+width-width*12/640,top+height*12/360,(0,255,0)),(left+width*12/640,top+height-height*12/360,(0,0,255)),(left+width-width*12/640,top+height-height*12/360,(255,255,255))]:near(image,x,y,color)
     values=[]
     for y in (top+height*16/360,top+height-height*16/360):
      value=0
      for bit in range(16):
       pixel=image.getpixel((round(left+width*.2+(bit+.5)*width*.6/16),round(y)));assert max(pixel)-min(pixel)<=2 and (max(pixel)<10 or min(pixel)>245),pixel
       if min(pixel)>245:value|=1<<bit
      values.append(value)
     assert values[0]==values[1] and values[0]>0,values
     return values[0]
    stamps={};images={}
    for name in ('active-a','active-b'):
     path=results/(name+'.png');image=Image.open(path).convert('RGB');assert image.size==(1280,720)
     near(image,640,360,(255,255,0));values=[stamp(image,640,360,640,360)]
     values.extend(stamp(image,160,470-i*110,160,90) for i in range(buffers))
     assert max(values)-min(values)<=buffers+2 and len(set(values[1:]))==buffers,values
     stamps[name]=values;images[name]=hashlib.sha256(path.read_bytes()).hexdigest()
    assert all(b>a for a,b in zip(stamps['active-a'],stamps['active-b'])),stamps
    return stamps, images
