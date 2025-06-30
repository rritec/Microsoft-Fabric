a = 10
b =10.33
c="ram"
l =[10,20,30]
def fun_square(arg1):
    return arg1 ** 2

class parrot:
    # class level attributes
    color = "green"
    num_of_legs= 2

    # instance(object) level attribute 
    ## __init__ is also called as constructor
    
    def __init__(self,age,weight): # object level attributes
        self.page=age
        self.pweight=weight

    # function(if a function is available inside the cal;ss then it is called as Method)
    def abcd(self):
        print("i will not run when object is created because iam not a constructor")