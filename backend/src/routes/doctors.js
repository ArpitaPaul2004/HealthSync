import {Router} from "express";
import {prisma} from "../db.js";
import {authenticate,allowRoles} from "../middleware/auth.js";
const router=Router();
router.get("/",async(req,res)=>{
 const {search,specialization,city}=req.query;
 const doctors=await prisma.user.findMany({where:{role:"DOCTOR",...(specialization?{specialization:{contains:specialization}}:{}),...(search?{name:{contains:search}}:{} )},select:{id:true,name:true,email:true,phone:true,specialization:true,hospitalId:true}});
 res.json({doctors});
});
router.get("/:id",async(req,res)=>{
 const doctor=await prisma.user.findFirst({where:{id:req.params.id,role:"DOCTOR"},select:{id:true,name:true,specialization:true,phone:true,hospitalId:true}});
 if(!doctor)return res.status(404).json({error:"Doctor not found"}); res.json({doctor});
});
export default router;
