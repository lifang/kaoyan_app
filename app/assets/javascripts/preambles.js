$.fn.reorder = function() {
    //random array sort from
    //http://javascript.about.com/library/blsort2.htm
    function randOrd() {
        return(Math.round(Math.random())-0.5);
    }
    return($(this).each(function() {
        var $this = $(this);
        var $children = $this.children();
        var childCount = $children.length;

        if (childCount > 1) {
            $children.remove();

            var indices = new Array();
            for (i=0;i<childCount;i++) {
                indices[indices.length] = i;
            }
            indices = indices.sort(randOrd);
            $.each(indices,function(j,k) {
                $this.append($children.eq(k));
            });
        }
    }));
}

function local_save_start() {
    local_save_time = new Date();
    local_timer = self.setInterval(function(){
        local_save();
    }, 100);
}
//定时执行函数
function local_save() {
    var start_date = new Date();
    if (local_start_time <= 0) {
        if (parseInt(local_start_time) == parseFloat(local_start_time)) {            
            if ($("#read").length > 0) {
                $('#read').fadeTo("slow", 0, function(){
                    $(this).remove();
                    $("#write").fadeIn("show");
                });
                window.clearInterval(local_timer);
                reset_clock();
            } else {
                true_time = 0;
                error_time += 1;
                get_next_sentence();
            }           
        }
    }
    if (parseInt(local_start_time) == parseFloat(local_start_time)) {
        if (local_start_time >= 10) {
            $(".time").html("00:" + local_start_time.toString());
        } else {
            $(".time").html("00:0" + local_start_time.toString());
        }
        
    }
    var end_date = new Date();
    if ((end_date - local_save_time) > 500 && (end_date - local_save_time) < 5000) {
        local_start_time = Math.round((local_start_time - (end_date - local_save_time)/1000)*10)/10;        
    } else {
        local_start_time = Math.round((local_start_time - 0.1 - (end_date - start_date)/1000)*10)/10;
    }
    local_save_time = end_date;
}

//重新启动定时器
function reset_clock() {
    local_start_time = _ans_arr.length * 3;
    local_save_time = null;
    local_save_start();
}

//将句子的特殊标点全部去掉
function wanted_str(str){
    return str.replace(/"/g," ").replace(/:/g," ").replace(/;/g," ").
    replace(/\?/g," ").replace(/!/g," ").replace(/,/g," ").replace(/\./g," ").replace(/  /g," ");
}

function str2arr(str){
    if(str==null)return [];
    var a = str.split(" ");
    var r = [];
    var x = 0;
    for(var i=0;i<a.length;i++){
        if(a[i]!=""){
            r[x] = a[i];
            x++;
        }
    }
    return r;
}

//将句子中的词拆分成单个按钮
function arr_to_choice(arr){
    for(var i=0;i<arr.length;i++){
        document.getElementById("select").innerHTML +=
        "<button id='choice"+(i+1)+"' title=\""+arr[i]+"\" value=\""+arr[i]+"\" onclick='javascript:choose("+(i+1)+")'>"
        +arr[i]+"</button>";
    }
    $("#select").reorder();
}

//撤销
function backspace(){
    $("#select button").show();
    $("#current").html("");
//    if(_history.length==0)return;
//    var m = _history.pop();
//    $("#choice"+m).show();
//    var current = $("#current").html().split(" ");
//    current.pop();
//    current.pop();
//    if(current.length==0){
//        $("#current").html("");
//    }else{
//        $("#current").html(""+current.join(" ")+" ");
//    }
}

//选词
function choose(m){
    $("#choice"+m).hide();
    //_history.push(m);
    document.getElementById("current").innerHTML += ""+$("#choice"+m).val()+" ";
}

//检查是否做对
function check_sentence(){
    if($("#current").html() == _correct_answer+" "){
        true_time += 1;
        error_time = 0;
    } else {
        true_time = 0;
        error_time += 1;
    }
    get_next_sentence();
}

function get_next_sentence() {
    window.clearInterval(local_timer);
    $.ajax({
        async:true,
        data:{
            current_level : $("#current_level").val(),
            sentence_ids : $("#sentence_ids").val(),
            true_time : true_time,
            error_time : error_time,
            category_id : $("#category_id").val(),
            l_end_level : $("#l_end_level").val(),
            l_start_level : $("#l_start_level").val()
        },
        dataType:'script',
        url:"/preambles/next_sentence",
        type:'post'
    });
    return false;
}

function revoke_exam(){
    generate_flash_div(".tab");
    $(".tab #confirm").bind("click",function(){
        $.ajax({
            async:true,
            type: "POST",
            url: "/pretests/revoke_exam",
            dataType: "json",
            data:{
                category_id : category_id
            },
            success : function(data) {
                window.location.href="/"
            }
        })
    })
}

function create_plan(){
    var category=$("#category_id").val();
    var score=$("#target_score").val();
    var max_score=$("#max_score").val();
    if (score==""||score.length==0){
        tishi_alert("请输入您的期望分数");
        return false;
    }
    if (parseInt(score)>parseInt(max_score)){
        tishi_alert("对不起，我们只能承诺您的最好成绩是："+max_score+"分");
        return false;
    }
    $.ajax({
        async:true,
        type: "POST",
        url: "/preambles/create_plan.js",
        dataType: "script",
        data:{
            category_id : category,
            target_score : score
        }
    })
}

function update_info(){
    var email=$("#p_email").val();
    var myReg =new RegExp(/^\w+([-+.])*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/);
    if (email==""||email.length==0){
        tishi_alert("请输入邮箱");
        return false;
    }
    if ( !myReg.test(email)) {
        tishi_alert("邮箱格式不正确，请核实！")
        return false;
    }
    $("#p_infos").submit();
}


function judge_url(category_id){
    $.ajax({
        async:true,
        type: "POST",
        url: "/preambles/jugde_url",
        dataType: "json",
        data:{
            category_id : category_id
        },
        success : function(data) {
            if (data.redir){
                window.open(data.url,"_blank",'height=768px,width=1024px,left=100px,top=10px')
            }else{
                window.location.href=data.url
            }
            
        }
    })
}
