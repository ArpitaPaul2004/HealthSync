import {Router} from "express";
import {prisma} from "../db.js";
import {authenticate,allowRoles} from "../middleware/auth.js";
const router=Router();
router.use(authenticate);
router.get("/",async(req,res)=>{
 const where=req.user.role==="PATIENT"?{patientId:req.user.sub}:req.user.role==="DOCTOR"?{doctorId:req.user.sub}:{};
 const appointments=await prisma.appointment.findMany({where,include:{patient:{select:{id:true,name:true,phone:true}},doctor:{select:{id:true,name:true,specialization:true}},hospital:true},orderBy:{startsAt:"asc"}});
 res.json({appointments});
});
router.post("/",allowRoles("PATIENT"),async(req,res)=>{
 const {doctorId,hospitalId,startsAt,reason}=req.body;
 const date=new Date(startsAt);
 if(!doctorId || !startsAt || Number.isNaN(date.getTime()) || date<=new Date()) return res.status(400).json({error:"Valid doctorId and future startsAt are required"});
 const doctor=await prisma.user.findFirst({where:{id:doctorId,role:"DOCTOR"}});
 if(!doctor)return res.status(404).json({error:"Doctor not found"});
 const conflict=await prisma.appointment.findFirst({where:{doctorId,startsAt:date,status:"BOOKED"}});
 if(conflict)return res.status(409).json({error:"Doctor already has an appointment at that time"});
 const appointment=await prisma.appointment.create({data:{patientId:req.user.sub,doctorId,hospitalId,startsAt:date,reason}});
 res.status(201).json({appointment});
});
router.patch("/:id/cancel",async(req,res)=>{
 const item=await prisma.appointment.findUnique({where:{id:req.params.id}});
 if(!item)return res.status(404).json({error:"Appointment not found"});
 if(req.user.role==="PATIENT"&&item.patientId!==req.user.sub || req.user.role==="DOCTOR"&&item.doctorId!==req.user.sub)
   return res.status(403).json({error:"Not your appointment"});
 const appointment=await prisma.appointment.update({where:{id:item.id},data:{status:"CANCELLED"}});
 res.json({appointment});
});
router.patch("/:id/complete",allowRoles("DOCTOR","HOSPITAL_ADMIN"),async(req,res)=>{
 const a=await prisma.appointment.findUnique({where:{id:req.params.id}});
 if(!a)return res.status(404).json({error:"Appointment not found"});
 if(req.user.role==="DOCTOR"&&a.doctorId!==req.user.sub)return res.status(403).json({error:"Not your appointment"});
 res.json({appointment:await prisma.appointment.update({where:{id:a.id},data:{status:"COMPLETED"}})});
});
export default router;
