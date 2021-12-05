from tkinter import *

from PIL import ImageTk, Image 


class Showimage():
    def __init__(self, imagepath):
        image_to_show = Image.open(imagepath)
        self.window = Tk()
        
        canvas = Canvas(self.window, width = 900, height = 700)  
        img = ImageTk.PhotoImage(image_to_show)
        
        canvas.create_image(0,0, anchor=NW, image=img)
        canvas.grid(column=1, row = 0)
        
        self.window.title("Is this a Protest Image?")
        prtst_btn = Button(self.window, text="Protest", command=self.label_protest)
    
        prtst_btn.grid(column=0, row=1)

        no_prtst_btn = Button(self.window, text="No Protest", command=self.label_no_protest)

        no_prtst_btn.grid(column=2, row=1)
        
        
        self.window.mainloop()

    def label_protest(self):
        print('a protest')
        self.label = 1
        self.window.destroy()
        
    def label_no_protest(self):
        print('not a protest')
        self.label = 0
        self.window.destroy()