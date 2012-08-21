//提交答案
function check_answer(answer_id){
    if($(".hover_on").length==0){
        tishi_alert("请选择答案");
        return false;
    }
    next_word(answer_id);
}

//单词测试结束，记录level
function send_record(level){
    $.ajax({
        async:true,
        type: "POST",
        url: "/pretests/level_record",
        data:{
            fact_level : level,
            category_id : category_id
        },
        dataType: "json",
        success : function(data) {
            window.location.href="/preambles/sentence?category_id="+category_id
        }
    })
}
//判断测试答案，并加载下一个单词
function next_word(answer_id){
    window.clearInterval(local_timer);
    if($(".hover_on").attr("id")==answer_id){
        success_times +=1;
        error_times=0;
    }else{
        success_times=0;
        error_times+=1;
    }
    select_level(answer_id);
    if (level==max_level){
        send_record(min_level);
    }else{   
        $.ajax({
            async:true,
            type: "POST",
            url: "/pretests/other_words.js",
            data:{
                limit_ids : test_ids,
                level : level,
                category_id : category_id
            },
            dataType: "script",
            success : function(data) {
            }
        })
    }
}

//根据答案判断选词等级
function select_level(answer_id){
    total_step +=1;
    if(success_times==3){
        init();
        min_level=level;
        level=parseInt((level+max_level+1)/2);
    }else if(error_times==2 || (total_step==6&&success_times!=3)||(success_times==0&&(total_step==4||total_step==5))){
        init();
        max_level=level;
        level=parseInt((level+min_level+1)/2);
    }else{
        test_ids += answer_id+",";
    }
}



//初始化值
function init(){
    total_step=0;
    success_times=0;
    error_times=0;
    test_ids="";
}

//单词定时器
function local_save_start(id) {
    local_start_time=30;
    local_save_time = new Date();
    local_timer = self.setInterval(function(){
        local_save(id);
    }, 100);
}

// 定时结束加载另一个单词
function local_save(id) {
    if(local_start_time<=0){
        next_word(id);
    }    
    show_timer();
}

//显示计时器
function show_timer(){
    var start_date = new Date();
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

//听力定时器
function listen_start(id) {
    local_save_time = new Date();
    local_timer = self.setInterval(function(){
        listen_save(id);
    }, 100);
}

// 定时结束加载另一个单词
function listen_save(id) {
    if(local_start_time==0){
        next_listen(id);
    }
    show_timer();
}

//查看听力答案
function check_listen(id){
    if($(".hover_on").length==0){
        tishi_alert("请选择答案");
        return false;
    }
    next_listen(id);
}

//加载下一个听力
function next_listen(answer_id){
    window.clearInterval(local_timer);
    if($(".hover_on").html()==en_mean){
        success_times +=1;
        error_times=0;
    }else{
        success_times=0;
        error_times+=1;
    }
    select_level(answer_id);
    if (level==max_level){
        send_listen(min_level);
    }else{
        $.ajax({
            async:true,
            type: "POST",
            url: "/pretests/other_listens.js",
            data:{
                limit_ids : test_ids,
                level : level,
                category_id : category_id
            },
            dataType: "script"
        })
    }
}


//单词测试结束，记录level
function send_listen(level){
    $.ajax({
        async:true,
        type: "POST",
        url: "/pretests/level_listen",
        data:{
            fact_level : level,
            category_id : category_id
        },
        dataType: "json",
        success : function(data) {
            window.location.href="/preambles/test_result?category_id="+category_id
        }
    })
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