module MoziFESection
export BeamSection
export RectangleSection,HSection,ISection,BoxSection,PipeSection,CircleSection

@enum SectionType begin
    GENERAL_SECTION=0
    ISECTION=1
    HSECTION=2
    BOX=3
    PIPE=4
    CIRCLE=5
    RECTANGLE=6
end

struct BeamSection
    id::String
    hid::Int
    A::Float64
    I₂::Float64
    I₃::Float64
    J::Float64
    As₂::Float64
    As₃::Float64
    W₂::Float64
    W₃::Float64
    sec_type::SectionType
    sizes::Vector
    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,sec_type=GENERAL_SECTION,sizes=[])=new(string(id),hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,sec_type,sizes)
end

# function BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃)
#     id=string(id)
# end

function RectangleSection(id,hid,h,b)::BeamSection
    id=string(id)

    A=h*b
    I₃=b*h^3/12
    I₂=h*b^3/12

    # bb,aa=sort([h,b])
    # J=aa*bb^3*(1/3-0.21*bb/aa*(1-bb^4/12/aa^4))
    β = MembraneMeta(h, b)
    J = h * b * b * b * β

    As₂=5.0 / 6 * h * b
    As₃=5.0 / 6 * h * b
    W₃=I₃/h*2
    W₂=I₂/b*2

    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,RECTANGLE,[h,b])
end


function HSection(id,hid,h,b,tw,tf)::BeamSection
    id=string(id)

    A=b*tf*2+tw*(h-2*tf)

    β=MembraneMeta(tf, b)
    J=tf * b * b * b * β * 2
    β = MembraneMeta(tw, h - 2 * tf)
    J+=tw * (h - 2 * tf)^3 * β

    I₃=b*h^3/12-(b-tw)*(h-2*tf)^3/12
    I₂=2*tf*b^3/12+(h-2*tf)*tw^3/12
    As₂=tw * h
    As₃=5.0 / 3 * tf * b
    W₃=I₃/h*2
    W₂=I₂/b*2
    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,HSECTION,[h,b,tw,tf])
end

function ISection(id,hid,h,b1,b2,tw,tf1,tf2)::BeamSection
    id=string(id)

    hw=h-tf1-tf2
    A=b1*tf1+b2*tf2+tw*hw
    y0=(b1*tf1*(h-tf1/2)+b2*tf2*tf2/2+hw*tw*(hw/2+tf2))/A

    β=MembraneMeta(tf1, b1)
    J=tf1 * b1^3 * β
    β=MembraneMeta(tf2, b2)
    J+=tf2 * b2^3* β
    β = MembraneMeta(tw, h - tf1 - tf2)
    J+=tw * (h - tf1 - tf2)^3 * β

    I₃=tw*hw^3/12
    I₃+=b1*tf1^3/12+b1*tf1*(hw/2+tf1/2)^2
    I₃+=b2*tf2^3/12+b2*tf2*(hw/2+tf2/2)^2
    I₃-=A*(y0-h/2)^2

    I₂=b1^3*tf1/12+b2^3*tf2/12+tw^3*hw/12

    As₂=tw * h
    As₃=5.0 / 6 * tf1 * b1 + 5.0 / 6 * tf2 * b2
    W₃=I₃/max(y0,h-y0)
    W₂=I₂/max(b1/2,b2/2)

    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,ISECTION,[h,b1,b2,tw,tf1,tf2])
end


function BoxSection(id,hid,h,b,tw,tf)::BeamSection
    id=string(id)

    A=h*b-(h-2*tf)*(b-2*tw)
    
    a = 2 * ((b - tw) / tf + (h - tf) / tw)
    Ω= 2 * (h - tf) * (b - tw)
    c=Ω/a
    J=c*Ω
    
    I₃=b*h^3/12-(b-2*tw)*(h-2*tf)^3/12
    I₂=h*b^3/12-(h-2*tf)*(b-2*tw)^3/12

    As₂=2 * tw * h
    As₃=2 * tf * b
    W₃=I₃/h*2
    W₂=I₂/b*2
    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,BOX,[h,b,tw,tf])
end

function PipeSection(id,hid,d,t)::BeamSection
    id=string(id)

    A=π*d^2/4-π*(d-2*t)^2/4
    J=π*(d-t)/t*2*A
    I₃=π*d^4/64*(1-((d-2*t)/d)^4)
    I₂=I₃

    As₂=π * t * (d - t) / 2
    As₃=π * t * (d - t) / 2
    W₃=I₃/d*2
    W₂=W₃
    r=d/2
    J=π/32*(d^4-(d-2t)^4)
    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,PIPE,[d,t])
end

function CircleSection(id,hid,d)::BeamSection
    id=string(id)

    A=π*d^2/4
    J=π*d^4/32
    I₃=π*d^4/64
    I₂=I₃

    As₂=π * d * d / 4 * 0.9
    As₃=π * d * d / 4 * 0.9
    W₃=I₃/d*2
    W₂=W₃
    J=π*d^4/32
    BeamSection(id,hid,A,I₂,I₃,J,As₂,As₃,W₂,W₃,CIRCLE,[d])
end

function MembraneMeta(h, b)
    s = 0
    for i in 1:30
        m = 1.0 + 2 * i
        s += tanh(m * π * h / 2 / b) / m^5
    end
    β = 1.0 / 3 - b / (π^5 * h) * s
    return β
end

end
